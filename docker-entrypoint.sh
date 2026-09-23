#!/bin/sh

set -e

# True if the file exists and can be written.
# Workaround due to busybox `[ -w ]` checks always true for root, even on read-only mounts.
is_writable() {
    [ -f "$1" ] && ( : >> "$1" ) 2>/dev/null
}

# Change uid/gid of radicale if vars specified
if [ -n "$UID" ] || [ -n "$GID" ]; then
    # Fail on read-only container
    if ! is_writable /etc/passwd; then
        echo "You specified custom UID/GID (UID: $UID, GID: $GID)."
        echo "UID/GID can only be changed when not running the container with --read-only."
        echo "Please see the README.md for how to proceed and for explanations."
        exit 1
    fi

    if [ -n "$UID" ] && [ "$UID" != "$(id radicale -u)" ]; then
        usermod -o -u "$UID" radicale
    fi

    if [ -n "$GID" ] && [ "$GID" != "$(id radicale -g)" ]; then
        groupmod -o -g "$GID" radicale
    fi
fi

# Update config from Env if Env vars are defined
if env | grep -q "^RADICALE_CONFIG_"; then
    # Skip if config is read-only
    if is_writable /config/config; then
        /venv/bin/python /usr/local/bin/update_config_from_env.py
    else
        echo "Environment variable-based config update is disabled because the radicale config is not writable."
    fi
fi

# If requested and running as root, mutate the ownership of bind-mounts
if [ "$(id -u)" = "0" ] && [ "$TAKE_FILE_OWNERSHIP" = "true" ]; then
    chown -R radicale:radicale /data
fi

# Run radicale as the "radicale" user or any other command if provided
if [ "$(id -u)" = "0" ] && [ "$1" = "/venv/bin/radicale" ]; then
    exec su-exec radicale "$@"
else
    exec "$@"
fi
