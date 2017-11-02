#!/bin/sh
set -e

if [[ -n "$GID" ]]; then
    groupmod -o -g $GID radicale
fi

if [[ -n "$UID" ]]; then
    usermod -o -u $UID radicale
fi

# Re-set permission to the `radicale` user if current user is root
# This avoids permission denied if the data volume is mounted by root
if [ "$1" = 'radicale' -a "$(id -u)" = '0' ]; then
    chown -R radicale /data
    exec su-exec radicale "$@"
fi

exec "$@"
