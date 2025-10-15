#!/usr/bin/env bash
# reminder.sh
# Runs the reminder logic: prints assignment info and which students are pending.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# load config
CONFIG_FILE="$SCRIPT_DIR/../config/config.env"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file missing at $CONFIG_FILE"
  exit 1
fi
# shellcheck disable=SC1090
source "$CONFIG_FILE"

# load functions
# shellcheck disable=SC1090
source "$SCRIPT_DIR/functions.sh"

echo " Submission Reminder App"
echo " Assignment: ${ASSIGNMENT}"
echo " Deadline:   ${DEADLINE}"
echo " Message:    ${REMINDER_MESSAGE}"
echo "Students who have NOT submitted:"

if check_submissions; then
  # exit code of function is nonzero if any pending (we used that pattern)
  echo "---------------------------------------"
  echo "Please contact the above students to remind them."
else
  echo "All students have submitted. No reminders necessary."
fi
