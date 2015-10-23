
#!/bin/sh

program=${0##*/}

aportsdir=${APORTSDIR:-/repo/aports}
repodir=${REPODIR:-/repo/packages}


git clone $APORT_REPO /repo/aports

usage() {
	echo "usage: $program [-a APORTSDIR] [-d REPODIR] [-hp] [-l LOGPREFIX ]"
	echo "                [-r DEPREPO] REPOSITORY..."

	echo "options:"
	echo " -a  Set the aports base dir to APORTSDIR instead of $aportsdir"
	echo " -d  Set destination repository base dir to REPODIR instead of $repodir"
	echo " -h  Show this help and exit"
	echo " -l  Send build to logfile, prefixed by LOGPREFIX"
	echo " -p  Purge obsolete packages from REPODIR after build"
	echo " -r  Dependencies are found in DEPREPO"
	exit 1
}


listpackages() {
	for i in */APKBUILD; do
		cd "$aportsdir"/$1/${i%/*}
		abuild listpkg
	done
}

all_exist() {
	while [ $# -gt 0 ]; do
		[ -e "$1" ] || return 1
		shift 1
	done
	return 0
}

build() {
	local repo="$1" i needbuild

	cd "$aportsdir/$repo" || return 1

	# first we try copy everything possible and find out which we need
	# to rebuild. By doing this we might save us for rebuilding
	# needed when running 'abuild -R'
	for i in */APKBUILD; do
		export REPODEST="$repodir"
		cd "$aportsdir/$repo"/${i%/*} || return 1
		if abuild -k -q up2date 2>/dev/null; then
			echo "$repo/${i%/*} up2date"
			continue
		fi

		# try link or copy the files if they are in the ports dir
		pkgs=$(abuild listpkg)
		if all_exist $pkgs; then
			echo ">>> Copying " $pkgs
			cp -p -l $pkgs "$repodir/$repo"/ 2>/dev/null \
				|| cp -p $pkgs "$repodir/$repo"/ \
				|| needbuild="$needbuild $i"
		else
			needbuild="$needbuild $i"
		fi
	done

	# build the postponed packages if any
	if [ -n "$needbuild" ]; then
		for i in $needbuild; do
			cd "$aportsdir/$repo"/${i%/*} || return 1
			abuild -k -R || return 1
		done
	fi

	# kill old packages in repo
	if [ -n "$dopurge" ]; then
		local tmp=$(mktemp /tmp/$program-XXXXXX)
		local purgefiles
		cd "$repodir/$1" || return 1
		trap 'rm -f "$tmp"; exit 1' INT
		( listpackages "$1") >$tmp
		purge=$(ls *.apk 2>/dev/null | grep -v -w -f $tmp)
		if [ -n "$purge" ]; then
			rm -f $purge
		fi
		rm -f "$tmp"
	fi

	# generate the repository index
	echo ">>> Generating Index for $repo..."
	cd "$repodir/$repo"
	local deps
	for i in $deprepo; do
		deps="--repo $repodir/$i"
	done
	oldindex=
	if [ -f APKINDEX.tar.gz ]; then
		oldindex="--index APKINDEX.tar.gz"
	fi
	tmpindex=$(mktemp).tar.gz
	apk index $oldindex -o $tmpindex \
		--description "$repo $(cd $aportsdir && git describe)" \
		*.apk
	abuild-sign $tmpindex && mv $tmpindex APKINDEX.tar.gz
	chmod 644 APKINDEX.tar.gz
	rm -f tmp.*
}

while getopts "a:d:hl:pr:" opt; do
	case "$opt" in
		a) aportsdir=$OPTARG;;
		d) repodir=$OPTARG;;
		h) usage >&2;;
		l) logprefix=$OPTARG;;
		p) dopurge=1;;
		r) deprepo="$deprepo $OPTARG";;
	esac
done
shift $(($OPTIND - 1))

[ $# -eq 0 ] && usage >&2

while [ $# -gt 0 ]; do
	if [ -n "$logprefix" ]; then
		build $1  >$logprefix.$1.log 2>&1 || exit 1
	else
		build $1 || exit 1
	fi
	deprepo="$deprepo $1"
	shift
done
