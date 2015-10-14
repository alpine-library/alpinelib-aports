#!/bin/sh

export REPO= /repo/x86_64/

apk index -o /repo/x86_64/APKINDEX.tar.gz /repo/x86_64/*.apk
abuild-sign -k ~/alpine-devel@example.com-5629d7e6.rsa /repo/x86_64/APKINDEX.tar.gz
