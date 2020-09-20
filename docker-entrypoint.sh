#!/bin/sh

set -e

if [ -n "$GID" ]; then
    groupmod -o -g "$GID" radicale
fi

if [ -n "$UID" ]; then
    usermod -o -u "$UID" radicale
fi

# Clone Git repository if enabled
if [ -n "$GIT_REPOSITORY" ] && [ -n "$GIT_USERNAME" ] && [ -n "$GIT_EMAIL" ]; then
    git clone "$GIT_REPOSITORY" /data/collections

    # Git needs to know an identity for pushing changes
    git config --system user.name "$GIT_USERNAME"
    git config --system user.email "$GIT_EMAIL"
fi

# Re-set permission to the `radicale` user if current user is root
# This avoids permission denied if the data volume is mounted by root
if [ "$1" = 'radicale' ] && [ "$(id -u)" = '0' ]; then
    chown -R radicale:radicale /data
    exec su-exec radicale "$@"
else
  exec "$@"
fi
