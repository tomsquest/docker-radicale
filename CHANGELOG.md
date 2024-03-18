# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [3.1.9.0] - 2024-03-18

## Changed

- [Update to Radicale 3.1,9](https://github.com/tomsquest/docker-radicale/pull/132)

## [3.1.8.3] - 2023-07-16

## Changed

- [Update alpine to 3.18.2](https://github.com/tomsquest/docker-radicale/pull/132)

## [3.1.8.2] - 2023-04-18

## Changed

- [Update alpine to 3.17.3](https://github.com/tomsquest/docker-radicale/pull/131)

## [3.1.8.1] - 2023-02-22

## Changed

- [Update alpine to 3.17.2](https://github.com/tomsquest/docker-radicale/pull/127)
- [Drop support for arm/v7](https://github.com/tomsquest/docker-radicale/pull/128)

## [3.1.8.0] - 2022-07-19

## Changed

- Upgrade to [Radicale 3.1.8](https://github.com/Kozea/Radicale/blob/master/CHANGELOG.md#318)

## [3.1.7.0] - 2022-04-21

## Changed

- Upgrade to [Radicale 3.1.7](https://github.com/Kozea/Radicale/blob/master/CHANGELOG.md#317)

## [3.1.6.0] - 2022-04-21

## Changed

- Upgrade to [Radicale 3.1.6](https://github.com/Kozea/Radicale/blob/master/CHANGELOG.md#316)

## [3.1.5.1] - 2022-03-05

## New

- [#117](https://github.com/tomsquest/docker-radicale/pull/117): add openssh for git ssh remotes

## [3.1.5.0] - 2022-02-10

## Changed

- Upgrade to [Radicale 3.1.5](https://github.com/Kozea/Radicale/blob/master/CHANGELOG.md#315)

## [3.1.4.0] - 2022-02-02

## Changed

- Upgrade to [Radicale 3.1.4](https://github.com/Kozea/Radicale/blob/master/CHANGELOG.md#314)

## [3.1.3.0] - 2022-01-22

## Changed

- Upgrade to [Radicale 3.1.3](https://github.com/Kozea/Radicale/blob/master/CHANGELOG.md#313)

## [3.1.2.0] - 2022-01-22

## Changed

- Upgrade to [Radicale 3.1.2](https://github.com/Kozea/Radicale/blob/v3.1.2/CHANGELOG.md#312)

## [3.1.1.0] - 2022-01-19

## Changed

- [#116](https://github.com/tomsquest/docker-radicale/pull/116): Upgrade to [Radicale 3.1.1](https://github.com/Kozea/Radicale/blob/4822807c4d0ab8863aa600354315d99eeeef1209/CHANGELOG.md#311) 

## [3.1.0.0] - 2022-01-02

### Changed

- [#113](https://github.com/tomsquest/docker-radicale/pull/113): Upgrade to [Radicale 3.1.0](https://github.com/Kozea/Radicale/blob/master/NEWS.md#310)

## [3.0.6.6] - 2021-12-30

### Added

- [#111](https://github.com/tomsquest/docker-radicale/pull/111): We now provide a RaspberryPI-compatible image. We now build the image for amd64, armv7, and arm64. 

## [3.0.6.5] - 2021-12-14

## Fixed

- [#107](https://github.com/tomsquest/docker-radicale/pull/107): this fix allows running the container with `--user`. Before that, `su-exec` (to run as `radicale` user) was always running whatever the current user.

## [3.0.6.4] - 2021-11-04

## Changed

- [#103](https://github.com/tomsquest/docker-radicale/pull/103): Drop support for `i386` and `arm` architectures (keep `amd64` and `arm64`). Support for this two architectures have been removed, as `i386` was not working for quite some time due to a bug in the build script (so, as no one noticed, certainly no one was using it), and I was unable to find a base alpine image that works for `arm`. Anyway, we keep the two majors architecture: `amd64` and `arm64`.

## [3.0.6.3] - 2021-10-12

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
