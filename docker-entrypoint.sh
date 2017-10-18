#!/bin/sh
set -e

# Re-set permission to the `radicale` user if current user is root
# This avoids permission denied if the data volume is mounted by root
if [ "$1" = 'radicale' -a "$(id -u)" = '0' ]; then
    chown -R radicale /data
    exec su-exec radicale "$@"
fi

exec "$@"
