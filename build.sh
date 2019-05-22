#!/bin/bash

set -euo pipefail

arch="$1"

case "$arch" in
    amd64   ) base_image="balenalib/amd64-alpine:3.9" ;;
    i386    ) base_image="balenalib/i386-alpine:3.9" ;;
    arm     ) base_image="balenalib/armv7hf-alpine:3.9" ;;
    aarch64 ) base_image="balenalib/aarch64-alpine:3.9" ;;
esac

sed "1cFROM $base_image" Dockerfile > "Dockerfile.$arch"
