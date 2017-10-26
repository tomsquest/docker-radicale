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
* Process management: use [Tini](https://github.com/krallin/tini) to handle init (pid 0)
* Safe volume permissions: `/config` and `/data` can be mounted by your user or root and they will still be readable by the `radicale` user inside the container
* Small size: run on [python:3-alpine](https://hub.docker.com/_/python/)
* Git and Bcrypt included for [versioning](http://radicale.org/versioning/) and [authentication](http://radicale.org/setup/#authentication)

## Radicale Version & Image Tag

This image aims to be tagged along Radicale.  

For example, given Radicale releases version `2.1.8`, we update the `VERSION` in the Dockerfile, then push a Git tag `2.1.8.0`.  
This will automatically produce a corresponding Docker image version on [Docker HUB](https://hub.docker.com/r/tomsquest/docker-radicale) to be pulled, eg. `docker pull tomsquest/docker-radicale:2.1.8.0`.  
The last number (x.y.z.LASTNUMBER) is our image revision. We increment it when we change something in the image without updating the version of Radicale.

At all time, the `master` branch is released as version `latest` on Docker HUB. You can pull latest with: `docker pull tomsquest/docker-radicale:latest` or simply `docker pull tomsquest/docker-radicale`

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
     -v ~/radicale/data:/data \
    tomsquest/docker-radicale
```

Run latest, keeps the stored data and a custom config:

```
docker run -d --name radicale \
    -p 5232:5232 \
     --read-only \
     -v ~/radicale/data:/data \
     -v ~/radicale/config:/config:ro \
    tomsquest/docker-radicale
```
Run latest, using custom UID and GID (`--read-only` is not possible with this method):

```
docker run -d --name radicale \
    -p 5232:5232 \
     --read-only \
     -e UID=1111 \
     -e GID=2222 \
     -v ~/radicale/data:/data \
     -v ~/radicale/config:/config:ro \
    tomsquest/docker-radicale
```

## User/Group ID

If you want another user to run the docker container and so "share" files with fixed permission between the host and the container, two options:
1. Create a user on your host with ID `2999` (hardcoded in the built image): `useradd --uid 2999 radicale`
2. Specify `-e UID=123` and `-e GID=456` for user and group Id's. `--read-only` is not possible with this method as it modifes the filesystem at runtime.
3. Or build the image yourself and specify the user ID you want: `docker build -t radicale --build-arg=UID=5000 --build-arg=GID=5001 .` (see the [Building](#Building) section below)

The first option is far easier. [Robert Beal](https://github.com/tomsquest/docker-radicale/pull/9#issuecomment-337834890) said it simply:
> The main problem with **building** is that you either have to do so on your own environment (and push the image to your own registry so that prod can access it) or you build on your production environment (which isn't ideal either). It means dealing with source code and git pulls etc... and you have to manage updating it all so more responsibility is put on the consumer.

## Building

Build the image:

```
docker build -t radicale .
```

Then run the container:

```
docker run -d --name radicale -p 5232:5232 radicale
```

When building, you can specify the user ID and group ID of the `radicale` user created in the container. 
This is useful because files created by the `radicale` user can then match one of your user on your host.  
This is an optional feature of this image.  
By default, the `radicale` user has a user ID of `2999` and a group ID of `2999`.
By the way, we could have "change" the IDs when the container is run, but this would prevent us from running the container readonly (with the `--read-only` flag).

```
# Let's create a user/group 5000/5001 on your host
sudo addgroup --gid 5001 radicale
sudo adduser --gid 5001 --uid 5000 --shell /bin/false --disabled-password --no-create-home radicale
# Then build the image with these IDs
docker build -t radicale --build-arg=UID=5000 --build-arg=GID=5001 .
```

## Radicale configuration

Radicale configuration is in one file `config`.

To customize Radicale configuration, either: 
* (recommended): use this repository preconfigured [config file](config/config),
* Or, get the [config file](https://raw.githubusercontent.com/Kozea/Radicale/master/config) from Radicale repository and tweak it (change `hosts` to be accessible from the Docker host, `filesystem_folder` to point to the data volume...)

Then puts these two files in a directory and use the config volume `-v /my_custom_config_directory:/config` when running the container.

## Contributors

* [Robert Beal](https://github.com/robertbeal): fixed userId, versionning...
* [Loader23](https://github.com/Loader23): config volume idea
* [Thomas Queste](https://github.com/tomsquest): initial image
