FROM alpine:3.8
LABEL maintainer="tom@tomsquest.com"

ARG VERSION=2.1.9
ARG UID=2999
ARG GID=2999

RUN apk add --no-cache --virtual=build-dependencies \
        gcc \
        libffi-dev \
        musl-dev \
        python3-dev \
    && apk add --no-cache \
        curl \
        git \
        python3 \
        shadow \
        su-exec \
    && python3 -m pip install radicale==$VERSION passlib[bcrypt] \
    && python3 -m pip install --upgrade git+https://github.com/Unrud/RadicaleInfCloud \
    && apk del --purge build-dependencies \
    && addgroup -g $GID radicale \
    && adduser -D -s /bin/false -H -u $UID -G radicale radicale \
    && mkdir -p /config /data \
    && chown -R radicale /config /data

COPY config /config

HEALTHCHECK --interval=30s --retries=3 CMD curl --fail http://localhost:5232 || exit 1
VOLUME /config /data
EXPOSE 5232

COPY docker-entrypoint.sh /usr/local/bin
RUN chmod 550 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["radicale", "--config", "/config/config"]
