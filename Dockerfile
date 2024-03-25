FROM alpine:3.19.1

ARG COMMIT_ID
ENV COMMIT_ID ${COMMIT_ID}

ARG VERSION
ENV VERSION ${VERSION:-3.1.9}

ARG BUILD_UID
ENV BUILD_UID ${BUILD_UID:-2999}

ARG BUILD_GID
ENV BUILD_GID ${BUILD_GID:-2999}

ARG TAKE_FILE_OWNERSHIP
ENV TAKE_FILE_OWNERSHIP ${TAKE_FILE_OWNERSHIP:-true}

LABEL maintainer="Thomas Queste <tom@tomsquest.com>" \
      org.label-schema.name="Radicale Docker Image" \
      org.label-schema.description="Enhanced Docker image for Radicale, the CalDAV/CardDAV server" \
      org.label-schema.url="https://github.com/Kozea/Radicale" \
      org.label-schema.version=$VERSION \
      org.label-schema.vcs-ref=$COMMIT_ID \
      org.label-schema.vcs-url="https://github.com/tomsquest/docker-radicale" \
      org.label-schema.schema-version="1.0"

RUN apk add --no-cache --virtual=build-dependencies \
        gcc \
        musl-dev \
        libffi-dev \
        python3-dev \
    && apk add --no-cache \
        curl \
        git \
        openssh \
        shadow \
        su-exec \
        tzdata \
        wget \
        python3 \
        py3-tz \
        py3-pip \
    && python -m venv /venv \
    && /venv/bin/pip install --no-cache-dir radicale==$VERSION passlib[bcrypt] \
    && apk del --purge build-dependencies \
    && addgroup -g $BUILD_GID radicale \
    && adduser -D -s /bin/false -H -u $BUILD_UID -G radicale radicale \
    && mkdir -p /config /data \
    && chmod -R 770 /data \
    && chown -R radicale:radicale /data \
    && rm -fr /root/.cache

COPY config /config/config

HEALTHCHECK --interval=30s --retries=3 CMD curl --fail http://localhost:5232 || exit 1
VOLUME /config /data
EXPOSE 5232

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/venv/bin/radicale", "--config", "/config/config"]
