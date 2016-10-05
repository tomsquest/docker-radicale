FROM debian:jessie
MAINTAINER Thomas Queste <tom@tomsquest.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install -y \
        python2.7 \
        python-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip install radicale dumb-init

RUN useradd -m radicale
ENV HOME /home/radicale
WORKDIR /home/radicale
USER radicale
COPY config /radicale
WORKDIR /radicale

EXPOSE 5232
VOLUME ["/home/radicale"]

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["radicale", "--config", "/radicale/config"]
