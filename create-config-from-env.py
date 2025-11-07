#!/usr/bin/env python3

import os
import re
import sys
from pathlib import Path
from collections import defaultdict

CONFIG_FILE = os.environ.get('RADICALE_CONFIG_FILE', '/config/config')

# Check if any RADICALE_CONFIG_ environment variables are set
has_config_vars = any(key.startswith('RADICALE_CONFIG_') for key in os.environ)

# If no config variables are provided, exit without touching the config
if not has_config_vars:
    sys.exit(0)

print("Applying configuration from environment variables...")

# Create config directory if it doesn't exist
config_path = Path(CONFIG_FILE)
config_path.parent.mkdir(parents=True, exist_ok=True)

# If config file doesn't exist, create an empty one
if not config_path.exists():
    config_path.touch()

# Read the existing config file
with open(CONFIG_FILE, 'r') as f:
    lines = f.readlines()

# Parse environment variables
env_configs = {}
for key, value in os.environ.items():
    if key.startswith('RADICALE_CONFIG_'):
        config_path_str = key[16:]  # Remove RADICALE_CONFIG_ prefix
        parts = config_path_str.lower().split('_', 1)
        if len(parts) == 2:
            section = parts[0]
            param = parts[1].replace('_', ' ').replace(' ', '_')
            if section not in env_configs:
                env_configs[section] = {}
            env_configs[section][param] = value
            print(f"Setting [{section}] {param} = {value}")

# Process the config file
output_lines = []
current_section = None
section_keys_updated = defaultdict(set)

i = 0
while i < len(lines):
    line = lines[i]
    stripped = line.strip()

    # Check if this is a section header
    section_match = re.match(r'^\[(\w+)\]', stripped)
    if section_match:
        current_section = section_match.group(1)
        output_lines.append(line)

        # If we have config for this section, check if keys exist in the section
        # We only add keys here that don't exist; existing keys will be replaced when encountered
        if current_section in env_configs:
            for key, value in env_configs[current_section].items():
                if key not in section_keys_updated[current_section]:
                    # Look ahead to see if this key exists in the section (uncommented or commented)
                    # Check if there's an uncommented version first
                    key_found_uncommented = False
                    key_found_commented = False
                    j = i + 1
                    while j < len(lines):
                        next_line = lines[j].strip()
                        # Stop if we hit another section
                        if re.match(r'^\[\w+\]', next_line):
                            break
                        # Check if this line contains our key
                        # First check for uncommented version
                        uncommented_pattern = re.compile(r'^' + re.escape(key) + r'\s*=')
                        if uncommented_pattern.match(next_line):
                            key_found_uncommented = True
                            break
                        # Then check for commented version
                        commented_pattern = re.compile(r'^#' + re.escape(key) + r'\s*=')
                        if commented_pattern.match(next_line) and not key_found_commented:
                            key_found_commented = True
                        j += 1

                    # If key found (either way), it will be replaced when encountered
                    # If not found at all, add it now
                    if not key_found_uncommented and not key_found_commented:
                        output_lines.append(f"{key} = {value}\n")
                        section_keys_updated[current_section].add(key)

        i += 1
        continue

    # Check if this line is a key=value pair in our target section
    if current_section and current_section in env_configs:
        # First check if it's an uncommented key = value
        uncommented_match = re.match(r'^(\w+)\s*=', stripped)
        if uncommented_match:
            key = uncommented_match.group(1)
            if key in env_configs[current_section] and key not in section_keys_updated[current_section]:
                # Replace this uncommented line with the new value
                output_lines.append(f"{key} = {env_configs[current_section][key]}\n")
                section_keys_updated[current_section].add(key)
                i += 1
                continue

        # Then check if it's a commented key = value
        commented_match = re.match(r'^#(\w+)\s*=', stripped)
        if commented_match:
            key = commented_match.group(1)
            if key in env_configs[current_section] and key not in section_keys_updated[current_section]:
                # Only replace commented line if no uncommented version exists
                # Check if there's an uncommented version later in the section
                has_uncommented = False
                j = i + 1
                while j < len(lines):
                    next_line = lines[j].strip()
                    if re.match(r'^\[\w+\]', next_line):
                        break
                    if re.match(r'^' + re.escape(key) + r'\s*=', next_line):
                        has_uncommented = True
                        break
                    j += 1

                if not has_uncommented:
                    # No uncommented version exists, so replace this commented one
                    output_lines.append(f"{key} = {env_configs[current_section][key]}\n")
                    section_keys_updated[current_section].add(key)
                    i += 1
                    continue

    output_lines.append(line)
    i += 1

# Add any sections that didn't exist
for section, keys in env_configs.items():
    if section not in section_keys_updated or not section_keys_updated[section]:
        # Check if section exists at all
        section_exists = any(re.match(r'^\[' + section + r'\]', line.strip()) for line in output_lines)
        if not section_exists:
            output_lines.append(f"\n[{section}]\n")
            for key, value in keys.items():
                output_lines.append(f"{key} = {value}\n")

# Write the updated config
with open(CONFIG_FILE, 'w') as f:
    f.writelines(output_lines)

print(f"Configuration updated at {CONFIG_FILE}")
