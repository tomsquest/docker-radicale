# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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
