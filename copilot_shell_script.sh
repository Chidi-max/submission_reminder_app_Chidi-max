#!/usr/bin/env bash
# copilot_shell_script.sh
# Prompts for an assignment name and updates the ASSIGNMENT value in config/config.env
# Then runs startup.sh to check pending students for that assignment.

set -euo pipefail

# --- Step 1: Find submission_reminder directories (case-insensitive)
mapfile -t matches < <(find . -maxdepth 1 -type d -iname "submission_reminder_*" -printf "%P\n")

# --- Step 2: Handle no matches or multiple matches
if [ "${#matches[@]}" -eq 0 ]; then
  echo "No submission_reminder directories found in $(pwd)."
  echo "Run create_environment.sh first or run this script from the repository root."
  exit 1
elif [ "${#matches[@]}" -gt 1 ]; then
  echo "Multiple submission_reminder directories found:"
  for i in "${!matches[@]}"; do
    printf "%s) %s\n" "$((i+1))" "${matches[$i]}"
  done
  read -p "Enter the number of the directory you want to update: " sel
  sel=$((sel - 1))
  env_dir="${matches[$sel]}"
else
  env_dir="${matches[0]}"
fi

# --- Step 3: Check if config.env exists
config_file="$env_dir/config/config.env"

if [ ! -f "$config_file" ]; then
  echo "Config file not found at $config_file"
  exit 1
fi

# --- Step 4: Prompt user for new assignment name
read -p "Enter the new assignment name (no spaces recommended or quote it): " new_assignment
if [[ -z "$new_assignment" ]]; then
  echo "Assignment name cannot be empty."
  exit 1
fi

# --- Step 5: Escape special characters for sed
escaped=$(printf "%s" "$new_assignment" | sed -e 's/[\/&]/\\&/g')

# --- Step 6: Update ASSIGNMENT in config.env
if grep -q '^ASSIGNMENT=' "$config_file"; then
  sed -i "s/^ASSIGNMENT=.*/ASSIGNMENT=\"${escaped}\"/" "$config_file"
else
  echo "ASSIGNMENT=\"${new_assignment}\"" >> "$config_file"
fi

echo "Updated ASSIGNMENT in $config_file to: ${new_assignment}"

# --- Step 7: Run startup.sh
echo "Now running startup.sh to check pending students for the new assignment..."
bash "$env_dir/scripts/startup.sh"

