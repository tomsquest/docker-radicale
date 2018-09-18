# Docker-Radicale

[![Build Status](https://travis-ci.org/tomsquest/docker-radicale.svg?branch=master)](https://travis-ci.org/tomsquest/docker-radicale)
[![Docker Build Status](https://img.shields.io/docker/build/tomsquest/docker-radicale.svg)](https://hub.docker.com/r/tomsquest/docker-radicale/)
[![GitHub tag](https://img.shields.io/github/tag/tomsquest/docker-radicale.svg)](https://github.com/tomsquest/docker-radicale/tags)
[![](https://img.shields.io/docker/pulls/tomsquest/docker-radicale.svg)](https://hub.docker.com/r/tomsquest/docker-radicale/)
[![](https://img.shields.io/docker/stars/tomsquest/docker-radicale.svg)](https://hub.docker.com/r/tomsquest/docker-radicale/)
[![](https://img.shields.io/docker/automated/tomsquest/docker-radicale.svg)](https://hub.docker.com/r/tomsquest/docker-radicale/)

Docker image for [Radicale](http://radicale.org), the CalDAV/CardDAV server.  
This container is for Radicale version 2.x, as of 2017.07.

## Features

* **Secured**: run as a normal user, not root
* **Enhanced**: add Git for [versioning](http://radicale.org/versioning/), Bcrypt for [authentication](http://radicale.org/setup/#authentication) and [InfCloud](https://www.inf-it.com/open-source/clients/infcloud/) as an alternative UI

## Version, Tags and Multi-architecture

This image aims to be tagged along Radicale, with:
- an additional number is appended corresponding to the version of our Dockerfile
- one build per architecture: i386, amd64, arm, aarch64

Example:

For Radicale version 2.1.10, those tags are created:
- `tomsquest/docker-radicale:i386.2.1.10.0`
- `tomsquest/docker-radicale:amd64.2.1.10.0`
- `tomsquest/docker-radicale:arm.2.1.10.0`
- `tomsquest/docker-radicale:aarch64.2.1.10.0`

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

Sharing files from the host and the container can be problematic because 
the `radicale` user **in** the container does not match the user running the container **on** the host.

To solve this, this image offers three options (see below for details):

- Create a user/group with id `2999` on the host
- Specify a custom user/group id on `docker run`
- Build the image with a custom user/group

#### Option 1. User/Group 2999

The image creates a user and a group with Id `2999`.  
You can create an user/group on your host matching this Id.

Example:

```bash
sudo addgroup --gid 2999 radicale
sudo adduser --gid 2999 --uid 2999 --shell /bin/false --disabled-password --no-create-home radicale
```

#### Option 2. Custom User/Group at run

The user and group Ids used in the image can be overridden when the container is run.  
This is done with the `UID` and `GID` env variables, eg. `docker run -e UID=123 -e GID=456 tomsquest/docker-radicale`.

**Beware**, the `--read-only` run flag cannot be used in this case. Using custom UID/GID at runtime modifies the filesystem and the modification is made impossible with the `--read-only` flag.

#### Option 3. Custom User/Group at build

You can build the image with custom user and group Ids and still use the `--read-only` flag.  
But, you will have to keep up-do-date with this image.

Usage: `docker build --build-arg=UID=5000 --build-arg=GID=5001 .` 

## Custom configuration

To customize Radicale configuration, either: 

* (recommended): use this repository preconfigured [config file](config/config),
* Or, use the original [config file](https://raw.githubusercontent.com/Kozea/Radicale/master/config) and:
  1. set `hosts = 0.0.0.0:5232`
  1. set `filesystem_folder = /data/collections`

Then use a config volume when running the container: `-v /my_custom_config_directory:/config`.

## Contributing

To run the tests (your user will need to be a member of the `docker` group)

1. `pip install pipenv`
1. `pipenv install -d`
1. `pytest -v test.py`

## Releasing

Create a Git tag, eg. 2.1.10.0, push it and Travis will build the images and publish them on Docker hub.

## Contributors

* [Robert Beal](https://github.com/robertbeal): fixed/configurable userId, versioning...
* [Loader23](https://github.com/Loader23): config volume idea
* [Waja](https://github.com/waja): less layers is more, InfCloud integration (UI for Radicale) 
* [Thomas Queste](https://github.com/tomsquest): initial image
