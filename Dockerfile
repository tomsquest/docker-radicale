FROM python:3-alpine
MAINTAINER Thomas Queste <tom@tomsquest.com>

ENV VERSION=2.1.8

RUN apk add --no-cache --virtual=build-dependencies \
        gcc \
        libffi-dev \
        musl-dev \
    && apk add --no-cache \
        git \
        su-exec \
        tini \
    && pip install radicale==$VERSION passlib[bcrypt] \
    && apk del --purge build-dependencies

# Create user and its group, with no home and no password
ARG UID=2999
ARG GID=2999
RUN addgroup -g $GID radicale && \
 adduser -D -s /bin/false -H -u $UID -G radicale radicale && \
 mkdir -p /config /data && chown -R radicale /config /data

COPY config /config

VOLUME /config /data
EXPOSE 5232

# Tini starts our entrypoint which then starts Radicale
COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["/sbin/tini", "--", "docker-entrypoint.sh"]
CMD ["radicale", "--config", "/config/config"]
