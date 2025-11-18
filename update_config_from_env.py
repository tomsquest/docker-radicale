#!/usr/bin/env python3
"""
Update Radicale configuration from environment variables.

Environment variables starting with RADICALE_ will be used to update
the configuration file. The format is: RADICALE_SECTION_KEY=value

Examples:
  RADICALE_SERVER_HOSTS=0.0.0.0:5232
  RADICALE_AUTH_TYPE=none
  RADICALE_STORAGE_FILESYSTEM_FOLDER=/data/collections
"""

import os
from configparser import ConfigParser
from pathlib import Path

ENV_PREFIX = "RADICALE_"


def update_config_from_env(config_path: str):
    config_file = Path(config_path)
    if not config_file.exists():
        print(f"Error: Config file {config_path} does not exist")
        return
    if not os.access(config_file, os.R_OK | os.W_OK):
        print(f"Error: Config file {config_path} is not readable or writable")
        return

    config = ConfigParser()
    config.read(config_file)

    changes_made = False

    for env_var, value in os.environ.items():
        if not env_var.startswith(ENV_PREFIX):
            continue

        parts = env_var[len(ENV_PREFIX):].lower().split("_", 1)
        if len(parts) < 2:
            print(f"Warning: Invalid environment variable format: {env_var}")
            continue

        section, key = parts

        if not config.has_section(section):
            config.add_section(section)

        config.set(section, key, value)
        print(f"Updated [{section}] {key} = {value}")
        changes_made = True

    if changes_made:
        with open(config_file, "w") as f:
            config.write(f)
        print(f"Config updated at {config_path}")


if __name__ == "__main__":
    update_config_from_env("/config/config")
