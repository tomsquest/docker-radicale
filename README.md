<p align="center">
<img src="logo.png" alt="Logo" />
</p>

<h1 align="center">Docker-Radicale</h1>

<p align="center">
<a href="https://github.com/tomsquest/docker-radicale/actions/workflows/build.yaml"><img src="https://github.com/tomsquest/docker-radicale/actions/workflows/build.yaml/badge.svg" alt="Build Status" /></a>
<a href="https://github.com/tomsquest/docker-radicale/tags"><img src="https://img.shields.io/github/tag/tomsquest/docker-radicale.svg" alt="GitHub tag" /></a>
<a href="https://hub.docker.com/r/tomsquest/docker-radicale/"><img src="https://img.shields.io/docker/pulls/tomsquest/docker-radicale.svg" alt="Pulls" /></a>
<a href="https://hub.docker.com/r/tomsquest/docker-radicale/"><img src="https://img.shields.io/docker/stars/tomsquest/docker-radicale.svg" alt="Stars" /></a>
</p>

<p align="center">
Enhanced Docker image for <a href="https://radicale.org">Radicale</a>, the CalDAV/CardDAV server.
</p>

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

## Table of contents

- [Features](#features)
- [Changelog](#changelog)
- [Versions](#versions)
    - [Version Tag Format](#version-tag-format)
- [Architectures](#architectures)
- [Running](#running)
    - [Option 1: **Basic** instruction](#option-1-basic-instruction)
    - [Option 2: **Recommended, Production-grade** instruction (secured, safe...) :rocket:](#option-2-recommended-production-grade-instruction-secured-safe-rocket)
    - [Docker Compose](#docker-compose)
- [Custom configuration](#custom-configuration)
- [Authentication configuration](#authentication-configuration)
- [Volumes versus Bind-Mounts](#volumes-versus-bind-mounts)
- [Running with Docker compose](#running-with-docker-compose)
- [Unraid](#unraid)
- [Extending the image](#extending-the-image)
    - [Birthday Calendar](#birthday-calendar)
- [Versioning with Git](#versioning-with-git)
- [Custom User/Group ID for the data volume](#custom-usergroup-id-for-the-data-volume)
    - [Option 0: Do nothing, permission will be fixed by the container itself](#option-0-do-nothing-permission-will-be-fixed-by-the-container-itself)
    - [Option 1: Create a user/group with id `2999` on the host](#option-1-create-a-usergroup-with-id-2999-on-the-host)
    - [Option 2: Force the user/group ids on `docker run`](#option-2-force-the-usergroup-ids-on-docker-run)
    - [Option 3: Build the image with a custom user/group](#option-3-build-the-image-with-a-custom-usergroup)
- [Running with Podman](#running-with-podman)
- [Running behind Caddy](#running-behind-caddy)
- [Contributing](#contributing)
- [Releasing](#releasing)
- [Contributors](#contributors)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Features

* :closed_lock_with_key: **Secured**: the container is read-only, with only access to its data dir, and without extraneous privileges
* :fire: **Safe**: run as a normal user (not root)
* :building_construction: **Multi-architecture**: run on amd64 and arm64
* :gear: **Easy configuration**: configure Radicale using environment variables (e.g., `RADICALE_SERVER_HOSTS=0.0.0.0:5232`)
* :sparkles: **Batteries included**:
    * git and ssh included for [versioning](https://github.com/tomsquest/docker-radicale/#versioning-with-git)
    * Python ldap3 for [LDAP authentication](https://github.com/Kozea/Radicale/wiki/LDAP-authentication)
    * Python pytz for proper timezone handling
    * Python bcrypt and argon2 for password hashing

## Changelog

:page_with_curl: See [CHANGELOG.md](CHANGELOG.md)

## Versions

Two image versions are available:

- **`latest`**: Based on `alpine:3` with **daily** automated builds to include the most recent security patches
- **Version tags** (e.g., `1.2.3.4`): Specific Radicale versions with image updates

**Which should you use?**

- Use `tomsquest/docker-radicale:latest` for always-updated security patches (daily build)
- Use `tomsquest/docker-radicale:$version` for stability with a specific Radicale version

### Version Tag Format

Version tags follow this format: `[Radicale version].[Image revision]`

For example, in `1.2.3.4`:

- `1.2.3` is the Radicale version
- The final `.4` is our image revision number, incremented for image-specific updates

### Latest version

- `latest` is build every day
- [Check the Releases page on GitHub](https://github.com/tomsquest/docker-radicale/releases)

## Architectures

The image is built for two architectures:

- `amd64`: for your usual server
- `arm64`: for Raspberry Pi

When you run the image, Docker will automatically select the correct image architecture.

## Running

### Option 1: **Basic** instruction

```
docker run -d --name radicale \
    -p 5232:5232 \
    -v ./data:/data \
    tomsquest/docker-radicale
```

### Option 2: **Recommended, Production-grade** instruction (secured, safe...) :rocket:

This is the most secured instruction:

```
docker run -d --name radicale \
    -p 127.0.0.1:5232:5232 \
    --init \
    --read-only \
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
    -v ./data:/data \
    tomsquest/docker-radicale
```

Note on capabilities:

- `CHOWN` is used to restore the permission of the `data` directory. Remove this if you do not need the `chown` to be run (see [below](#volumes-versus-bind-mounts))
- `SETUID` and `SETGID` are used to run radicale as the less privileged `radicale` user (with su-exec), and are required.
- `KILL` is to allow Radicale to exit, and is required.

### Docker Compose

A [Docker compose file](docker-compose.yml) is included.

## Custom configuration

You can configure Radicale in two ways:

### Option 1: Using environment variables (recommended for simple configurations)

You can configure Radicale using environment variables without mounting a config file. Environment variables starting with `RADICALE_` will automatically update the configuration file at container startup.

The format is: `RADICALE_SECTION_KEY=value`

Examples:

```bash
docker run -d --name radicale \
    -p 5232:5232 \
    -e RADICALE_SERVER_HOSTS=0.0.0.0:5232 \
    -e RADICALE_AUTH_TYPE=none \
    -e RADICALE_STORAGE_FILESYSTEM_FOLDER=/data/collections \
    -v ./data:/data \
    tomsquest/docker-radicale
```

⚠️ Notes:

1. Setting environment variables will rewrite the config file, removing any comments.
2. Environment variables don't work with `--read-only` containers. Use a custom config file instead (see Option 2 below).
3. Use exact case for values (e.g., `True`, not `true`). Check the [config file](config) for correct casing.

### Option 2: Using a custom config file

To change Radicale configuration, first get the config file:

* use this preconfigured [config file](config) from this repository,
* Or, use [the original Radicale config file](https://raw.githubusercontent.com/Kozea/Radicale/master/config) and:
    1. set `hosts = 0.0.0.0:5232`
    2. set `filesystem_folder = /data/collections`
    3. set `[auth] type = none`

Then:

1. create a config directory (eg. `mkdir -p /my_custom_config_directory`)
2. copy your config file into the config folder (e.g. `cp config /my_custom_config_directory/config`)
3. mount your custom config volume when running the container: `-v /my_custom_config_directory:/config:ro`.
   The `:ro` at the end make the volume read-only, and is more secured.

**Note**: Environment variables will override values in the config file if both are present.

## Authentication configuration

This section shows a basic example of configuring authentication for Radicale using htpasswd with bcrypt algorithm.  
To learn more, refer to [the official Radicale document](https://radicale.org/v3.html#auth).

First, we need to configure Radicale to use htpasswd authentication and specify htpasswd file's location.  
Create a `config` file inside the `config` directory (resulting in the path `config/config`).

```
[server]
hosts = 0.0.0.0:5232

[auth]
type = htpasswd
htpasswd_filename = /config/users
htpasswd_encryption = bcrypt

[storage]
filesystem_folder = /data/collections
```

Next, create a `users` file inside the `config` directory (resulting in the path `config/users`).  
Each line contains the username and bcrypt-hashed password, separated by a colon (`:`).

```
john:$2a$10$l1Se4qIaRlfOnaC1pGt32uNe/Dr61r4JrZQCNnY.kTx2KgJ70GPSm
sarah:$2a$10$lKEHYHjrZ.QHpWQeB/feWe/0m4ZtckLI.cYkVOITW8/0xoLCp1/Wy
```

Finally, create and run the container using the appropriate volume mount.
In this example, both files are stored in the same directory (`./config`).

```bash
docker run -d --name radicale tomsquest/docker-radicale \
    -p 5232:5232 \
    -v ./data:/data \
    -v ./config:/config:ro
```

## Volumes versus Bind-Mounts

This section is related to the error message `chown: /data: Permission denied`.

With [Docker volumes](https://docs.docker.com/storage/volumes/), and not [bind-mounts](https://docs.docker.com/storage/bind-mounts/) like shown in the examples above, you may need to disable the container trying to make the `data` directory writable.

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
It can also be [extended](https://docs.docker.com/compose/production/#modify-your-compose-file-for-production).  
Make sure you have Docker compose version 2 or higher.

## Unraid

This image is compatible with Unraid, and you can find it in the [Community App store](https://unraid.net/community/apps?q=radicale#r).

## Extending the image

The image is extendable, as per Docker image architecture. You need to create your own `Dockerfile`.

For example, here is how to add [RadicaleIMAP](https://github.com/Unrud/RadicaleIMAP) (authenticate by email)
and [RadicaleInfCloud](https://www.inf-it.com/open-source/clients/infcloud/) (an alternative UI) to the image.

Please note that the [radicale-imap](https://gitlab.com/comzeradd/radicale-imap) plugin is not compatible with
Radicale 3.0 anymore!

First, create a `Dockerfile.extended` (pick the name you want) with this content:

```dockerfile
FROM tomsquest/docker-radicale

RUN /venv/bin/pip install git+https://github.com/Unrud/RadicaleIMAP
RUN /venv/bin/pip install git+https://github.com/Unrud/RadicaleInfCloud
```

Then, build and run it:

```bash
docker build -t radicale-extended -f Dockerfile.extended .
docker run --name radicale-extended -p 5232:5232 radicale-extended
```

### Birthday Calendar

[Christof Schulze](https://github.com/christf) provides an extended image to include [Radicale Birthday Calendar](https://github.com/iBigQ/radicale-birthday-calendar).

Find its [project here](https://github.com/christf/docker-radicale-birthday) to add a birthday calendar to your Radicale instance.

## Versioning with Git

Radicale supports a hook which is executed after each change to the CalDAV/CardDAV files.
This hook can be used to keep a versions of your CalDAV/CardDAV files through git.

This image provides `git` to support this feature.

Refer to the [official documentation of Radicale](https://radicale.org/v3.html#versioning-with-git) for the details.

## Custom User/Group ID for the data volume

You will certainly mount a volume to keep Radicale data between restart/upgrade of the container.
But sharing files from the host and the container can be problematic.
The reason is that `radicale` user **in** the container does not match the user running the container **on** the host.

To solve this, this image offers four options (see below for details):

- Option 0: Do nothing, permission will be fixed by the container itself
- Option 1: Create a user/group with id `2999` on the host
- Option 2: Force the user/group ids on `docker run`
- Option 3: Build the image with a custom user/group

### Option 0: Do nothing, permission will be fixed by the container itself

When running the container with a /data volume (e.g. `-v ./data:/data`), the container entrypoint will automatically fix the permissions on `/data`.

This option is OK, but not optimal:

- Ok for the container, as inside the container, the `radicale` user can read and write its data
- But on the host, the data directory will then be owned by the user/group 2999:2999

### Option 1: Create a user/group with id `2999` on the host

The image creates a user and a group with id `2999` in the container.  
You can create a user/group on your host matching this id.

Example:

```bash
# On your host
sudo addgroup --gid 2999 radicale
sudo adduser --gid 2999 --uid 2999 --shell /bin/false --disabled-password --no-create-home radicale
```

### Option 2: Force the user/group ids on `docker run`

The user and group ids used in the container can be overridden when the container is run.  
This is done with the `UID` and `GID` env variables, e.g. `docker run -e UID=123 -e GID=456 ...`.  
This will force all operations to be run with this UID/GID.

:warning: The **`--read-only`** run flag cannot be used in this case.
Using custom UID/GID tries to modify the filesystem at runtime but this is made **impossible** by the `--read-only` flag.

### Option 3: Build the image with a custom user/group

You can build the image with custom user and group ids and still use the `--read-only` flag.  
But you will have to clone this repo, do a local build and keep up with changes of this image.

Usage: `docker build --build-arg=BUILD_UID=5000 --build-arg=BUILD_GID=5001 ...`.

`BUILD_UID` and `BUILD_GID` are also supported as environment variables to work around a problem on some Synology NAS. See this PR#68.

## Running with Podman

Two users have given the instructions they used to run the image with Podman:

- [@greylinux's instructions](https://github.com/tomsquest/docker-radicale/issues/122#issuecomment-1361240992)
- [@strauss115's instructions](https://github.com/tomsquest/docker-radicale/issues/122#issuecomment-1874607285)

## Running behind Caddy

[Caddy](https://caddyserver.com) is sitting in front of all my self-hosted services, like Radicale.  
It brings https and security (basic authentication).

The following Caddyfile works for me. Note that I don't use Radicale authentication, I have only one user.

```caddyfile
radicale.yourdomain.com {
    reverse_proxy 127.0.0.1:5232

    basicauth {
        tom pas$w0rd
    }
}
```

## Contributing

To run the tests:

1. `uv sync`
2. `uv run pytest -v`

## Releasing

```bash
# Update local tags
git fetch --all --tags
# Update `CHANGELOG.md` (after the PR is merged)
...
# Create tag
TAG=1.2.3.4 && git tag $TAG && git push origin $TAG
# Draft a new release
xdg-open https://github.com/tomsquest/docker-radicale/releases/new
```

Note: the `latest` tag is generated automatically on each push (and daily).

## Contributors

* [Oscar Carlsson](https://github.com/oscarcarlsson): update Radicale to 3.5.5
* [Emil Miller](https://github.com/realcharmer): update Radicale to 3.3.0
* [Nate Harris](https://github.com/nwithan8): add image to Unraid community app store
* [SalaryTheft](https://github.com/SalaryTheft): add section about Authentication configuration
* [Dillbyrne](https://github.com/dillbyrne): update alpine
* [Jauder Ho](https://github.com/jauderho): update alpine
* [Greylinux](https://github.com/Greylinux): running with podman
* [Tionis](https://github.com/tionis): add openssh for git ssh remotes
* [flixhsw](https://github.com/flixhsw): support armv7 (Raspberry) and simplify the CI using Docker Buildx
* [hecd](https://github.com/hecd): fix to run su-exec only when the actual user is root
* [Jake Mayeux](https://github.com/jakemayeux): change "data" folder to `./data` instead of `~/radicale/data` in docker-compose.yml and doc
* [Thomas](https://github.com/symgryph): reduce image size (/root/.cache) and Alpine upgrade
* [Bernard Kerckenaere](https://github.com/bernieke): check for read-only container, and help for volumes versus bind-mounts
* [Dylan Van Assche](https://github.com/DylanVanAssche): hook to read/write to a Git repo
* [Adzero](https://github.com/adzero): override build args with environment variables
* [Robert Beal](https://github.com/robertbeal): fixed/configurable userId, versioning...
* [Loader23](https://github.com/Loader23): config volume idea
* [Waja](https://github.com/waja): fewer layers is more, InfCloud integration (UI for Radicale)
* [Christian Burmeister](https://github.com/christianbur): add tzdata to be able to specify timezone
* [Silas Lenz](https://github.com/silaslenz): add pytz for recurring events
* [Enno Richter](https://github.com/elohmeier): bcrypt support
* [Andrew u frank](https://github.com/andrewufrank): house-cleaning of whitespaces in doc
* [Marcus Kimpenhaus](https://github.com/kimpenhaus): fix for Alpine and https
* [Thomas Queste](https://github.com/tomsquest): initial image
