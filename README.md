<p align="center">
<img src="logo.png" alt="Logo" />
</p>

<h1 align="center">Docker-Radicale</h1>

<p align="center">
<a href="https://travis-ci.org/tomsquest/docker-radicale"><img src="https://travis-ci.org/tomsquest/docker-radicale.svg?branch=master" alt="Build Status" /></a>
<a href="https://hub.docker.com/r/tomsquest/docker-radicale/"><img src="https://img.shields.io/docker/build/tomsquest/docker-radicale.svg" alt="Docker Build Status" /></a>
<a href="https://github.com/tomsquest/docker-radicale/tags"><img src="https://img.shields.io/github/tag/tomsquest/docker-radicale.svg" alt="GitHub tag" /></a>
<a href="https://hub.docker.com/r/tomsquest/docker-radicale/"><img src="https://img.shields.io/docker/pulls/tomsquest/docker-radicale.svg" alt="Pulls" /></a>
<a href="https://hub.docker.com/r/tomsquest/docker-radicale/"><img src="https://img.shields.io/docker/stars/tomsquest/docker-radicale.svg" alt="Stars" /></a>
<a href="https://hub.docker.com/r/tomsquest/docker-radicale/"><img src="https://img.shields.io/docker/automated/tomsquest/docker-radicale.svg" alt="Automated build" /></a>
</p>

<p align="center">
Enhanced Docker image for <a href="http://radicale.org">Radicale</a>, the CalDAV/CardDAV server.
</p>

## Features

* :closed_lock_with_key: **Secured**: run as a normal user, not root
* :sparkles: **Enhanced**: add Git for [versioning](http://radicale.org/versioning/), Bcrypt for [authentication](http://radicale.org/setup/#authentication) and [InfCloud](https://www.inf-it.com/open-source/clients/infcloud/) as an alternative UI
* :building_construction: **Multi-architecture**: run on amd64, arm (RaspberryPI...) and others 

## Version, Tags and Multi-architecture

**Latest tag**: ![latest tag](https://img.shields.io/github/tag/tomsquest/docker-radicale.svg)

Version number = Architecture + '.' + Radicale version + '.' + increment number

Example: those tags were created for Radicale 2.1.10:
- `tomsquest/docker-radicale:i386.2.1.10.0`
- `tomsquest/docker-radicale:amd64.2.1.10.0`
- `tomsquest/docker-radicale:arm.2.1.10.0`
- `tomsquest/docker-radicale:aarch64.2.1.10.0`

The last number is ours, incremented on changes. For example, 2.1.10.**2** made the /config readonly (this is specific to this image).

Additionally, Docker Hub automatically build and publish this image as `tomsquest/docker-radicale` (which by default is `amd64`).

## Running

**Minimal** instruction:

```
docker run -d --name radicale \
    -p 5232:5232 \
    tomsquest/docker-radicale
```

**Production-grade** instruction:

```
docker run -d --name radicale \
    -p 127.0.0.1:5232:5232 \
    --read-only \
    --init \
    --security-opt="no-new-privileges:true" \
    --cap-drop ALL \
    --cap-add CHOWN \
    --cap-add SETUID \
    --cap-add SETGID \
    --pids-limit 50 \
    --memory 256M \
    --health-cmd="curl --fail http://localhost:5232 || exit 1" \
    --health-interval=30s \
    --health-retries=3 \
    -v ~/radicale/data:/data \
    -v ~/radicale/config:/config:ro \
    tomsquest/docker-radicale
```

### Docker compose

A [Docker compose file](docker-compose.yml) is included. It can be [extended](https://docs.docker.com/compose/production/#modify-your-compose-file-for-production). 

## Custom User/Group ID for the data volume

You will certainly mount a volume to keep Radicale data between restart/upgrade of the container.
But sharing files from the host and the container can be problematic.
The reason is that `radicale` user **in** the container does not match the user running the container **on** the host.

To solve this, this image offers four options (see below for details):

- Option 0. Do nothing, permission will be fixed by the container itself
- Option 1. Create a user/group with id `2999` on the host
- Option 2. Specify a custom user/group id on `docker run`
- Option 3. Build the image with a custom user/group

#### Option 0. Do nothing, the container will fix the permission itself

When running the container with a /data volume (eg. `-v /mydata/radicale:/data`), the container entrypoint will automatically fix the permissions on `/data`. 

This option is OK but not optimal:
- Ok for the container, as inside it the radicale user can read and write its data
- But on the host, the data directory will then be owned by the user/group 2999:2999

#### Option 1. User/Group 2999 on the host

The image creates a user and a group with Id `2999`.  
You can create an user/group on your host matching this Id.

Example:

```bash
sudo addgroup --gid 2999 radicale
sudo adduser --gid 2999 --uid 2999 --shell /bin/false --disabled-password --no-create-home radicale
```

#### Option 2. Custom User/Group at run

The user and group Ids used in the image can be overridden when the container is run.  
This is done with the `UID` and `GID` env variables, eg. `docker run -e UID=123 -e GID=456 ...`.

But **beware**, the `--read-only` run flag cannot be used in this case. Using custom UID/GID tries to modify the filesystem at runtime but this is made impossible by the `--read-only` flag.

#### Option 3. Custom User/Group at build

You can build the image with custom user and group Ids and still use the `--read-only` flag.  
But, you will have to clone this repo, do a local build and keep up with changes of this image.

Usage: `docker build --build-arg=UID=5000 --build-arg=GID=5001 ...` 

## Custom configuration

To customize Radicale configuration, either: 

* Recommended: use this repository preconfigured [config file](config),
* Use the original [config file](https://raw.githubusercontent.com/Kozea/Radicale/master/config) and:
  1. set `hosts = 0.0.0.0:5232`
  1. set `filesystem_folder = /data/collections`

Then mount your custom config volume when running the container: `-v /my_custom_config_directory:/config`.

## Contributing

To run the tests (your user will need to be a member of the `docker` group)

1. `pip install pipenv`
1. `pipenv install -d`
1. `pytest -v`

## Releasing

Create a Git tag, eg. 2.1.10.0, push it and Travis will build the images and publish them on Docker hub.

## Contributors

* [Robert Beal](https://github.com/robertbeal): fixed/configurable userId, versioning...
* [Loader23](https://github.com/Loader23): config volume idea
* [Waja](https://github.com/waja): less layers is more, InfCloud integration (UI for Radicale) 
* [Thomas Queste](https://github.com/tomsquest): initial image
