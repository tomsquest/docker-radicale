#!/bin/sh

set -e

# Change uid/gid of radicale if vars specified
if [ -n "$UID" ] || [ -n "$GID" ]; then
    if [ ! "$UID" = "$(id radicale -u)" ] || [ ! "$GID" = "$(id radicale -g)" ]; then
        # Fail on read-only container
        if grep -e "\s/\s.*\sro[\s,]" /proc/mounts > /dev/null; then
            echo "You specified custom UID/GID (UID: $UID, GID: $GID)."
            echo "UID/GID can only be changed when not running the container with --read-only."
            echo "Please see the README.md for how to proceed and for explanations."
            exit 1
        fi

        if [ -n "$UID" ]; then
            usermod -o -u "$UID" radicale
        fi

        if [ -n "$GID" ]; then
            groupmod -o -g "$GID" radicale
        fi
    fi
fi

# If requested and running as root, mutate the ownership of bind-mounts
if [ "$(id -u)" = "0" ] && [ "$TAKE_FILE_OWNERSHIP" = "true" ]; then
    chown -R radicale:radicale /data
    chown -R radicale:radicale /config
fi

# Run radicale as the "radicale" user or any other command if provided
if [ "$(id -u)" = "0" ] && [ "$1" = "/venv/bin/radicale" ]; then
    exec su-exec radicale "$@"
else
    exec "$@"
fi
