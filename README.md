# Docker-Radicale

[![Build Status](https://travis-ci.org/tomsquest/docker-radicale.svg?branch=master)](https://travis-ci.org/tomsquest/docker-radicale)
[![](https://images.microbadger.com/badges/version/tomsquest/docker-radicale.svg)](https://microbadger.com/images/tomsquest/docker-radicale)
[![](https://images.microbadger.com/badges/image/tomsquest/docker-radicale.svg)](https://microbadger.com/images/tomsquest/docker-radicale)
[![](https://img.shields.io/docker/pulls/tomsquest/docker-radicale.svg)](https://hub.docker.com/r/tomsquest/docker-radicale/)
[![](https://img.shields.io/docker/stars/tomsquest/docker-radicale.svg)](https://hub.docker.com/r/tomsquest/docker-radicale/)
[![](https://img.shields.io/docker/automated/tomsquest/docker-radicale.svg)](https://hub.docker.com/r/tomsquest/docker-radicale/)

Docker image for [Radicale](http://radicale.org), the CalDAV/CardDAV server.  
This container is for Radicale version 2.x, as of 2017.07.

Special points:
* Security: run as normal user (not root!) with the help of [su-exec](https://github.com/ncopa/su-exec) ([gosu](https://github.com/tianon/gosu) in C)
* Safe: use [Tini](https://github.com/krallin/tini) to handle init
* Persistent volume: `/radicale/data` can be mounted by your user or root and will still be readable by the `radicale` user inside the container
* Small size: run on [python:3-alpine](https://hub.docker.com/_/python/)
* Configurable: [Radicale's config](config/config) can be modified before building this image

## Build & Run

Pull from Docker HUB:

```
docker pull tomsquest/docker-radicale
```

Or build the container locally:

```
docker build -t radicale .
```

Then, run the container:

```
docker run -d --name radicale -p 5232:5232 radicale
```

Or, better run it with persistent data and readonly filesystem:

```
docker run -d --name radicale -p 5232:5232 -v ~/radicale:/radicale/data --read-only radicale
```

## Radicale configuration

To customize Radicale configuration, clone this repository, edit [Radicale's config](config/config) and build it locally.

The [config/config](config/config) and [config/logging](config/logging) files comes from Radicale repo:
* https://raw.githubusercontent.com/Kozea/Radicale/master/config
* https://raw.githubusercontent.com/Kozea/Radicale/master/logging