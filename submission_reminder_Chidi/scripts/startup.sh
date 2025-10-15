#!/usr/bin/env bash
# startup.sh
# Start the submission reminder application

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# make sure scripts are executable
find "$SCRIPT_DIR" -maxdepth 1 -type f -name "*.sh" -exec chmod +x {} \;

# run the reminder
bash "$SCRIPT_DIR/reminder.sh"
