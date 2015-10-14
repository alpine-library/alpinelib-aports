FROM alpine:3.2
MAINTAINER ekozan

RUN apk --update add git abuild docker alpine-sdk \
  && rm -rf /var/cache/apk/*

VOLUME /repo
WORKDIR /repo

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY repo-build.sh /repo-build.sh
RUN chmod +x /repo-build.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["build"]
