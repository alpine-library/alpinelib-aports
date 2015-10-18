FROM alpine:3.2
MAINTAINER ekozan


RUN apk --update add dpkg gpgme git abuild docker alpine-sdk \
  && rm -rf /var/cache/apk/*

RUN adduser -S -G abuild abuild

RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& chmod +x /usr/local/bin/gosu

VOLUME /repo
WORKDIR /repo

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY repo-build.sh /repo-build.sh
RUN chmod +x /repo-build.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["build"]
