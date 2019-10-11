#!/bin/bash

set -euo pipefail

arch="$1"

case "$arch" in
    amd64   ) base_image="balenalib/amd64-alpine:3.10" ;;
    i386    ) base_image="balenalib/i386-alpine:3.10" ;;
    arm     ) base_image="balenalib/armv7hf-alpine:3.10" ;;
    aarch64 ) base_image="balenalib/aarch64-alpine:3.10" ;;
esac

sed "1cFROM $base_image" Dockerfile > "Dockerfile.$arch"
