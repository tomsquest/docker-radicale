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
* Security: run as a normal user (not root!) with the help of [su-exec](https://github.com/ncopa/su-exec) (ie. [gosu](https://github.com/tianon/gosu) in C)
* Process management: use [Tini](https://github.com/krallin/tini) to handle init (pid 0)
* Safe volume permissions: `/radicale/config` and `/radicale/data` can be mounted by your user or root and they will still be readable by the `radicale` user inside the container
* Small size: run on [python:3-alpine](https://hub.docker.com/_/python/)
* Git and Bcrypt included for [versioning](http://radicale.org/versioning/) and [authentication](http://radicale.org/setup/#authentication)

## Version/Tags

Github tags are automatically build as image's tags on [Docker HUB](https://hub.docker.com/r/tomsquest/docker-radicale).

`Latest` is branch `master`.  
`2.x` is Radicale `v2.x`.  
`1.x` is Radicale `v1.x`.  

## Running

Run latest:

```
docker run -d --name radicale \
    -p 5232:5232 \
    tomsquest/docker-radicale
```

Run latest and keeps the stored data:

```
docker run -d --name radicale \
    -p 5232:5232 \
     --read-only 
     -v ~/radicale/data:/radicale/data \
    tomsquest/docker-radicale
```

Run latest, keeps the stored data and a custom config:

```
docker run -d --name radicale \
    -p 5232:5232 \
     --read-only \
     -v ~/radicale/data:/radicale/data \
     -v ~/radicale/config:/radicale/config:ro \
    tomsquest/docker-radicale
```

## Building

Build the image:

```
docker build -t radicale .
```

Then run the container:

```
docker run -d --name radicale -p 5232:5232 radicale
```

## Radicale configuration

Radicale configuration is in one file `config` with an optional `logging` file.

To customize Radicale configuration: 
* Recommended: use this repository config files ([config](config/config), [logging](config/logging)),
* Or, get the ones from Radicale repository ([config](https://raw.githubusercontent.com/Kozea/Radicale/master/config), [logging](https://raw.githubusercontent.com/Kozea/Radicale/master/logging)) and tweaks them (changes `hosts` to be accessible from the Docker host, `filesystem_folder` to point to the data volume...)

Then puts these two files in a directory and use the config volume `-v /my_custom_config_directory:/radicale/config` when running the container.
