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

docker buildx build --push \
  --build-arg COMMIT_ID=$COMMIT_ID \
  --tag tomsquest/docker-radicale:$DOCKER_IMAGE_SUFFIX \
  --platform linux/amd64,linux/arm/v7,linux/arm64 .
