# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

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
