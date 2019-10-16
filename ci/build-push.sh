#!/bin/bash

set -eo pipefail

# Require to build docker image of other architectures
docker run --rm --privileged multiarch/qemu-user-static:register --reset

archs=(amd64 386 arm arm64)

if [ -z "$TRAVIS_TAG" ]
then
  DOCKERFILE_SUFFIX=""
  DOCKER_TAG="latest"
else
  DOCKERFILE_SUFFIX=".$TRAVIS_TAG"
  DOCKER_TAG="$TRAVIS_TAG"
fi

for arch in "${archs[@]}"
do
  case "$arch" in
    amd64   ) base_image="balenalib/amd64-alpine:3.10" ;;
    i386    ) base_image="balenalib/i386-alpine:3.10" ;;
    arm     ) base_image="balenalib/armv7hf-alpine:3.10" ;;
    arm64 ) base_image="balenalib/aarch64-alpine:3.10" ;;
  esac

  sed "1cFROM $base_image" Dockerfile > "Dockerfile.$arch"

  docker build \
    --build-arg COMMIT_ID=$TRAVIS_COMMIT \
    -t tomsquest/docker-radicale:$arch$DOCKERFILE_SUFFIX \
    --file Dockerfile.$arch .

  docker push tomsquest/docker-radicale:$arch$DOCKERFILE_SUFFIX
done

# Docker Manifest is experimental, need to enable it manually
export DOCKER_CLI_EXPERIMENTAL=enabled

docker manifest create tomsquest/docker-radicale:$DOCKER_TAG \
  tomsquest/docker-radicale:amd64$DOCKERFILE_SUFFIX \
  tomsquest/docker-radicale:386$DOCKERFILE_SUFFIX \
  tomsquest/docker-radicale:arm$DOCKERFILE_SUFFIX \
  tomsquest/docker-radicale:arm64$DOCKERFILE_SUFFIX

docker manifest annotate tomsquest/docker-radicale:$DOCKER_TAG \
  tomsquest/docker-radicale:amd64$DOCKERFILE_SUFFIX   --arch amd64
docker manifest annotate tomsquest/docker-radicale:$DOCKER_TAG \
  tomsquest/docker-radicale:386$DOCKERFILE_SUFFIX    --arch 386
docker manifest annotate tomsquest/docker-radicale:$DOCKER_TAG \
  tomsquest/docker-radicale:arm$DOCKERFILE_SUFFIX     --arch arm
docker manifest annotate tomsquest/docker-radicale:$DOCKER_TAG \
  tomsquest/docker-radicale:arm64$DOCKERFILE_SUFFIX --arch arm64

docker manifest push tomsquest/docker-radicale:$DOCKER_TAG
