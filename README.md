<p align="center">
<img src="logo.png" alt="Logo" />
</p>

<h1 align="center">Docker-Radicale</h1>

<p align="center">
<a href="https://travis-ci.org/tomsquest/docker-radicale"><img src="https://travis-ci.org/tomsquest/docker-radicale.svg?branch=master" alt="Build Status" /></a>
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
* :fire: **Safe**: the container is read-only, with only access to its data dir, and without extraneous privileges
* :sparkles: **Batteries included**: git included for [versioning](https://github.com/tomsquest/docker-radicale/#versioning-with-git) and Pytz for proper timezone conversion
* :building_construction: **Multi-architecture**: run on amd64, arm (RaspberryPI...) and others 

## Changelog

:page_with_curl: See [CHANGELOG.md](CHANGELOG.md)

## Latest version

**Latest tag**: ![latest tag](https://img.shields.io/github/tag/tomsquest/docker-radicale.svg)

## Running

**Minimal** instruction:

```
docker run -d --name radicale \
    -p 5232:5232 \
    tomsquest/docker-radicale
```

**Basic** instruction:

1. create the folders to store the data and the config: `mkdir -p /radicale/{data,config}`
1. copy the [config file](https://raw.githubusercontent.com/tomsquest/docker-radicale/master/config) into the config folder: `cp config /radicale/config/config`
1. Then run the container:

```
docker run -d --name radicale \
    -p 5232:5232 \
    tomsquest/docker-radicale \
    -v /radicale/data:/data \
    -v /radicale/config:/config:ro \
```

:rocket: **Production-grade** instruction (secured, safe...):

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
    --cap-add KILL \
    --pids-limit 50 \
    --memory 256M \
    --health-cmd="curl --fail http://localhost:5232 || exit 1" \
    --health-interval=30s \
    --health-retries=3 \
    -v ~/radicale/data:/data \
    -v ~/radicale/config:/config:ro \
    tomsquest/docker-radicale
```
  
Note on capabilities:
- `CHOWN` is used to restore the permission of the `data` directory. Skip it if not chowning (see below)
- `SETUID` and `SETGID` are used to run radicale as the less privileged `radicale` user (with su-exec)
- `KILL` is to allow Radicale to exit, and is always required.

## Volumes versus Bind-Mounts

This section is related to the error message `chown: /data: Permission denied`.

With [Docker volumes](https://docs.docker.com/storage/volumes/), and not [bind-mounts](https://docs.docker.com/storage/bind-mounts/) like shown in the examples above, 
you may need to disable the container trying to make the `data` directory writable.

This is done with the `TAKE_FILE_OWNERSHIP` environment variable.  
The variable will tell the container to perform or skip the `chown` instruction.  
The default value is `true`: the container will try to make the `data` directory writable to the `radicale` user.  

To disable the `chown`, declare the variable like this:

```
docker run -d --name radicale tomsquest/docker-radicale \
    -e "TAKE_FILE_OWNERSHIP=false"
```

## Running with Docker compose

A [Docker compose file](docker-compose.yml) is included. 
It can be [extended](https://docs.docker.com/compose/production/#modify-your-compose-file-for-production). 

## Extending the image

The image is extendable, as per Docker image architecture. You need to create your own `Dockerfile`.

For example, here is how to add [RadicaleIMAP](https://github.com/Unrud/RadicaleIMAP) (authenticate by email) 
and [RadicaleInfCloud](https://www.inf-it.com/open-source/clients/infcloud/) (an alternative UI) to the image.

Please note that the [radicale-imap](https://gitlab.com/comzeradd/radicale-imap) plugin is not compatible with
Radicale 3.0 anymore!

First, create a `Dockerfile.extended` (pick the name you want) with this content:

```dockerfile
FROM tomsquest/docker-radicale

RUN python3 -m pip install git+https://github.com/Unrud/RadicaleIMAP
RUN python3 -m pip install git+https://github.com/Unrud/RadicaleInfCloud
```

Then, build and run it:

```bash
docker build -t radicale-extended -f Dockerfile.extended .
docker run --name radicale-extended -p 5232:5232 radicale-extended
```

## Versioning with Git

Radicale supports a hook which is executed after each change to the CalDAV/CardDAV files.
This hook can be used to keep a versions of your CalDAV/CardDAV files through git.

This image provides `git` to support this feature. 

Refer to the [official documentation of Radicale](https://radicale.org/3.0.html#tutorials/versioning-with-git) 
for the details.

## Custom User/Group ID for the data volume

You will certainly mount a volume to keep Radicale data between restart/upgrade of the container.
But sharing files from the host, and the container can be problematic.
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

#### Option 2. Custom User/Group at run time

The user and group Ids used in the image can be overridden when the container is run.  
This is done with the `UID` and `GID` env variables, eg. `docker run -e UID=123 -e GID=456 ...`.

:warning: The **`--read-only`** run flag cannot be used in this case. Using custom UID/GID tries to modify the filesystem at runtime but this is made **impossible** by the `--read-only` flag.

#### Option 3. Custom User/Group at build time

You can build the image with custom user and group Ids and still use the `--read-only` flag.  
But, you will have to clone this repo, do a local build and keep up with changes of this image.

Usage: `docker build --build-arg=BUILD_UID=5000 --build-arg=BUILD_GID=5001 ...`.

`BUILD_UID` and `BUILD_GID` are also supported as environment variables to work around a problem on some Synology NAS. See this PR#68.

## Custom configuration

To customize Radicale configuration, either: 

* Recommended: use this repository preconfigured [config file](config),
* Use the original [config file](https://raw.githubusercontent.com/Kozea/Radicale/master/config) and:
  1. set `hosts = 0.0.0.0:5232`
  1. set `filesystem_folder = /data/collections`

Then mount your custom config volume when running the container: `-v /my_custom_config_directory:/config`.

## Multi-architecture

Starting from 2.1.11.3, this image has a manifest which allow you to just pull the image **without** supplying the
 architecture. The command `docker pull tomsquest/docker-radicale` will pull the correct image for your architecture.

Else, the image is also tagged with this scheme:

Version number = Architecture + '.' + Radicale version + '.' + This image increment number

Example: those tags were created for Radicale 3.0.6:
- `tomsquest/docker-radicale:386.3.0.6.0`
- `tomsquest/docker-radicale:amd64.3.0.6.0`
- `tomsquest/docker-radicale:arm.3.0.6.0`
- `tomsquest/docker-radicale:arm64.3.0.6.0`

The last number is **ours**, and it is incremented on new release. 

For example, 2.1.11.**2** made the /config readonly (this is specific to this image).

Additionally, Docker Hub automatically builds and [publish this image as `tomsquest/docker-radicale`](https://hub.docker.com/r/tomsquest/docker-radicale/).

## Contributing

To run the tests:

1. `pip install pipenv`
1. `pipenv install -d`
1. `pytest -v`

## Releasing

1. Create a Git tag, eg. `3.0.6.0`, push it and Travis will build the images and publish them on Docker hub
1. Update the `latest` tag

Example instructions :

```bash
# Next release
git tag 3.0.6.0
git push origin 3.0.6.0

# latest tag
git push --delete origin latest && git tag -d latest && git tag latest && git push origin latest
```

## Contributors

* [Thomas](https://github.com/symgryph): reduce image size (/root/.cache) and Alpine upgrade
* [Bernard Kerckenaere](https://github.com/bernieke): check for read-only container, and help for volumes versus bind-mounts
* [Dylan Van Assche](https://github.com/DylanVanAssche): hook to read/write to a Git repo
* [Adzero](https://github.com/adzero): override build args with environment variables
* [Robert Beal](https://github.com/robertbeal): fixed/configurable userId, versioning...
* [Loader23](https://github.com/Loader23): config volume idea
* [Waja](https://github.com/waja): less layers is more, InfCloud integration (UI for Radicale) 
* [Christian Burmeister](https://github.com/christianbur): add tzdata to be able to specify timezone 
* [Silas Lenz](https://github.com/silaslenz): add pytz for recurring events
* [Enno Richter](https://github.com/elohmeier): bcrypt support 
* [Andrew u frank](https://github.com/andrewufrank): house-cleaning of whitespaces in doc 
* [Marcus Kimpenhaus](https://github.com/kimpenhaus): fix for Alpine and https 
* [Thomas Queste](https://github.com/tomsquest): initial image
