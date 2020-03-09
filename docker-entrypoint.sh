#!/bin/sh

set -e

if [ -n "$PGID" ]; then
    groupmod -o -g "$PGID" radicale
fi

if [ -n "$PUID" ]; then
    usermod -o -u "$PUID" radicale
fi

# Re-set permission to the `radicale` user if current user is root
# This avoids permission denied if the data volume is mounted by root
if [ "$1" = 'radicale' ] && [ "$(id -u)" = '0' ]; then
    chown -R radicale:radicale /data
    exec su-exec radicale "$@"
else
  exec "$@"
fi
