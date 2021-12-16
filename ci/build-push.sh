#!/bin/bash

set -euo pipefail

TAG=${GITHUB_REF#refs/tags/}
COMMIT_ID=$(git rev-parse --short "$GITHUB_SHA")
echo "TAG: $TAG"
echo "COMMIT_ID: $COMMIT_ID"

if [ -z "$TAG" ] || [ "$TAG" = "latest" ]
then
  DOCKER_IMAGE_SUFFIX=""
else
  DOCKER_IMAGE_SUFFIX=".$TAG"
fi

archs=(amd64 arm64)
for arch in "${archs[@]}"
do
  case "$arch" in
    amd64 ) base_image="alpine:3.14" ;;
    arm64 ) base_image="balenalib/aarch64-alpine:3.14" ;;
  esac

  sed "1cFROM $base_image" Dockerfile > "Dockerfile.$arch"

  docker build \
    --build-arg COMMIT_ID=$COMMIT_ID \
    -t tomsquest/docker-radicale:$arch$DOCKER_IMAGE_SUFFIX \
    --file Dockerfile.$arch .

  docker push tomsquest/docker-radicale:$arch$DOCKER_IMAGE_SUFFIX
done

# Docker Manifest is experimental, need to enable it manually
export DOCKER_CLI_EXPERIMENTAL=enabled

docker manifest create tomsquest/docker-radicale:$TAG \
  tomsquest/docker-radicale:amd64$DOCKER_IMAGE_SUFFIX \
  tomsquest/docker-radicale:arm64$DOCKER_IMAGE_SUFFIX

docker manifest annotate tomsquest/docker-radicale:$TAG \
  tomsquest/docker-radicale:amd64$DOCKER_IMAGE_SUFFIX --arch amd64
docker manifest annotate tomsquest/docker-radicale:$TAG \
  tomsquest/docker-radicale:arm64$DOCKER_IMAGE_SUFFIX --arch arm64

docker manifest push tomsquest/docker-radicale:$TAG
