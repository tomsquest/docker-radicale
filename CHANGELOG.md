# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [3.0.6.5] - 20201-12-14

## Fixed

- [#107](https://github.com/tomsquest/docker-radicale/pull/107): this fix allows running the container with `--user`. Before that, `su-exec` (to run as `radicale` user) was always running whatever the current user.

## [3.0.6.4] - 20201-11-04

## Changed

- [#103](https://github.com/tomsquest/docker-radicale/pull/103): Drop support for `i386` and `arm` architectures (keep `amd64` and `arm64`). Support for this two architectures have been removed, as `i386` was not working for quite some time due to a bug in the build script (so, as no one noticed, certainly no one was using it), and I was unable to find a base alpine image that works for `arm`. Anyway, we keep the two majors architecture: `amd64` and `arm64`.

## [3.0.6.3] - 20201-10-12

## Changed

- [#97](https://github.com/tomsquest/docker-radicale/pull/97): upgraded to Alpine 3.14 and reduce image size by removing `/root/.cache`

## [3.0.6.2] - 2021-04-17

### Added

- [#91](https://github.com/tomsquest/docker-radicale/pull/91): add `TAKE_FILE_OWNERSHIP` environment variable to disable chown.
  This allows user using volumes, not bind-mount volumes, to skip the `chown` applied to files in `/data`

## [3.0.6.1] - 2021-03-20

### Removed

- Remove automatic git repository cloning using environment variables. This was not perfectly working (it would try to clone each time for instance).
  To ease maintenance, this feature was removed in favor of a manual step (you clone the repo yourself in the data volume).

## [3.0.6.0] - 2020-10-26

### Changed

- :sparkles: First version based on Radicale 3 ([version 3.0.6](https://github.com/Kozea/Radicale/blob/3.0.x/NEWS.md#306) exactly)

## [2.1.12.1] - 2020-06-03

### Added

- [#77](https://github.com/tomsquest/docker-radicale/pull/77): add pytz as a dependency. pytz is used by vobject and
  thus Radicale to correctly parse timezone. Timezone are required with recurring events and daylight savings.

## [2.1.12.0] - 2020-05-20

### Changed

- Update Radicale to [version 2.1.12](https://github.com/Kozea/Radicale/blob/2.1.12/NEWS.md)

## [2.1.11.6] - 2020-04-30

### Changed

- [#70](https://github.com/tomsquest/docker-radicale/issues/70): fix: Container does not start since [#68](https://github.com/tomsquest/docker-radicale/pull/68). The container now starts and custom UID/GID is supported.

## [2.1.11.5] - 2020-03-09

### Added

- [#68](https://github.com/tomsquest/docker-radicale/pull/68): Can use environment variable instead of build arguments. This is a workaround for a bug in Synology, but it also makes this image more flexible

### Changed

- [#65](https://github.com/tomsquest/docker-radicale/pull/65): Use the appropriate logging config from Radicale released branch (the config has changed on master and is not appropriate for release `2.1.11`)

### Removed

## [2.1.11.4] - 2019-10-16

### Added

- Docker manifest is published for `latest` and each tag

### Changed

- Architecture tag for `aarch64` is now `arm64` (conform to GOARCH value)
- Architecture tag for `i386` is now `386` (conform to GOARCH value)

### Removed

## [2.1.11.3] - 2019-10-11

### Added

### Changed

- Update alpine to version `3.10` for all supported architectures

### Removed

- [RadicaleInfCloud](https://github.com/Unrud/RadicaleInfCloud) is no more part of the image. Extend the image (see [README.md](README.md) for how-to)

## [2.1.11.2] - 2019-10-11

### Added

- `tzdata` package added to image to allow user to customize the timezone, eg. `-e TZ=Europe/Paris`.
- `wget` package added as alpine/busybox default wget is not linked against ssl, by [@kimpenhaus](https://github.com/kimpenhaus).

### Changed

- Switch Alpine base images (from `resin` to `balenalib`)

### Removed

## [Older] - Older

See [the github commit log](https://github.com/tomsquest/docker-radicale/commits/master)
