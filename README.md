# Docker-Radicale

[![Build Status](https://travis-ci.org/tomsquest/docker-radicale.svg?branch=master)](https://travis-ci.org/tomsquest/docker-radicale)
[![Docker Build Status](https://img.shields.io/docker/build/tomsquest/docker-radicale.svg)](https://hub.docker.com/r/tomsquest/docker-radicale/)
[![GitHub tag](https://img.shields.io/github/tag/tomsquest/docker-radicale.svg)](https://github.com/tomsquest/docker-radicale/tags)
[![](https://img.shields.io/docker/pulls/tomsquest/docker-radicale.svg)](https://hub.docker.com/r/tomsquest/docker-radicale/)
[![](https://img.shields.io/docker/stars/tomsquest/docker-radicale.svg)](https://hub.docker.com/r/tomsquest/docker-radicale/)
[![](https://img.shields.io/docker/automated/tomsquest/docker-radicale.svg)](https://hub.docker.com/r/tomsquest/docker-radicale/)

Docker image for [Radicale](http://radicale.org), the CalDAV/CardDAV server.  
This container is for Radicale version 2.x, as of 2017.07.

Special points:
* Security: run as a normal user (not root!) with the help of [su-exec](https://github.com/ncopa/su-exec) (ie. [gosu](https://github.com/tianon/gosu) in C)
* Safe volume permissions: `/config` and `/data` can be mounted by your user or root and they will still be readable by the `radicale` user inside the container
* Small size: run on [python:3-alpine](https://hub.docker.com/_/python/)
* Git and Bcrypt included for [versioning](http://radicale.org/versioning/) and [authentication](http://radicale.org/setup/#authentication) and [InfCloud](https://www.inf-it.com/open-source/clients/infcloud/) if you need an UI

## Radicale Version & Image Tag

This image aims to be tagged along Radicale.  

For example, given Radicale releases version `2.1.8`, we update the `VERSION` in the Dockerfile, then push a Git tag `2.1.8.0`.  
This will automatically produce a corresponding Docker image version on [Docker HUB](https://hub.docker.com/r/tomsquest/docker-radicale) to be pulled, eg. `docker pull tomsquest/docker-radicale:2.1.8.0`.  
The last number (x.y.z.LASTNUMBER) is our image revision. We increment it when we change something in the image without updating the version of Radicale.

At all time, the `master` branch is released as version `latest` on Docker HUB. You can pull latest with: `docker pull tomsquest/docker-radicale:latest`.

## Running

**Minimal** instruction:

```
docker run -d --name radicale \
    -p 5232:5232 \
    tomsquest/docker-radicale
```

**Production-grade** run:

```
docker run -d --name radicale \
    -p 127.0.0.1:5232:5232 \
    --read-only \
    --init \
    --pids-limit 50 \
    --security-opt="no-new-privileges:true" \
    --health-cmd="curl --fail http://localhost:5232 || exit 1" \
    --health-interval=30s \
    --health-retries=3 \
    -v ~/radicale/data:/data \
    -v ~/radicale/config:/config:ro \
    tomsquest/docker-radicale
```

### Docker compose

A [Docker compose file](docker-compose.yml) is included. It can be [extended](https://docs.docker.com/compose/production/#modify-your-compose-file-for-production). 

## User/Group ID

Sharing files from the host and the container can be problematic: 
the `radicale` user **in** the container does not match the user running the container **on** the host.

To solve this, this image offers three options:

- Use a user/group with id `2999` on the host
- Specify a custom user/group id on run
- Build the image with a custom user/group

#### User/Group 2999

The image creates a user and a group with Id `2999`.  
You can create an user/group on your host matching this Id.

Example:

```bash
sudo addgroup --gid 2999 radicale
sudo adduser --gid 2999 --uid 2999 --shell /bin/false --disabled-password --no-create-home radicale
```

#### Custom User/Group at run

The user and group Ids used in the image can be overridden when the container is run.  
This is done with the `UID` and `GID` env variables, eg. `docker run -e UID=123 -e GID=456 tomsquest/docker-radicale`.

**Beware**, the `--read-only` run flag cannot be used in this case. Using custom UID/GID at runtime modifies the filesystem and the modification is made impossible with the `--read-only` flag.

#### Custom User/Group at build

You can build the image with custom user and group Ids and still use the `--read-only` flag.  
But, you will have to keep up-do-date with this image.

Usage: `docker build --build-arg=UID=5000 --build-arg=GID=5001 .` 

## Radicale configuration

To customize Radicale configuration, either: 
* (recommended): use this repository preconfigured [config file](config/config),
* Or, use a custom config file
  1. get the [config file](https://raw.githubusercontent.com/Kozea/Radicale/master/config) from Radicale repository
  1. Change `hosts` to be accessible from the Docker host (thus, set `hosts = 0.0.0.0:5232`)
  1. Mount the config in the container `-v /my_custom_config_directory:/config`

Then puts these two files in a directory and use the config volume `-v /my_custom_config_directory:/config` when running the container.

## Contributing

First install the test dependencies

`pip install --user -r requirements.txt`

To run the tests

`pytest -v test.py`

## Contributors

* [Robert Beal](https://github.com/robertbeal): fixed/configurable userId, versioning...
* [Loader23](https://github.com/Loader23): config volume idea
* [Waja](https://github.com/waja): less layers is more, InfCloud integration (UI for Radicale) 
* [Thomas Queste](https://github.com/tomsquest): initial image
