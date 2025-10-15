#!/usr/bin/env bash
# create_environment.sh
# Creates the submission_reminder_{YourName} environment and files automatically.
# Usage: bash create_environment.sh

set -euo pipefail

echo "== Submission Reminder Environment Creator =="

read -p "Enter your name (no spaces recommended): " userName
if [[ -z "$userName" ]]; then
  echo "Name cannot be empty. Exiting."
  exit 1
fi

main_dir="submission_reminder_${userName}"

# If exists, confirm replacement (non-interactive here: remove old)
if [ -d "$main_dir" ]; then
  echo "Directory $main_dir already exists. Removing old version..."
  rm -rf "$main_dir"
fi

echo "Creating directory structure..."
mkdir -p "$main_dir"/{config,scripts,data}

# Create config/config.env with content
cat > "$main_dir/config/config.env" <<'CONFIG'
# Configuration file for submission reminder app
# The ASSIGNMENT entry is used by the reminder to check the submissions list.
ASSIGNMENT="Math_Assignment_1"
DEADLINE="2025-10-20"
REMINDER_MESSAGE="You have a pending submission!"
CONFIG

# Create scripts/functions.sh
cat > "$main_dir/scripts/functions.sh" <<'FUNCS'
#!/usr/bin/env bash
# functions.sh
# Utility functions for the submission reminder app

# Globals:
# DATA_FILE expected at ../data/submissions.txt (relative to scripts/)

DATA_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/data/submissions.txt"

# Print pending students for the given assignment (if students have statuses per assignment)
# Expected submissions.txt format per line:
# Student Name,status
# where status is "submitted" or "pending"
check_submissions() {
  if [ ! -f "$DATA_FILE" ]; then
    echo "Data file not found: $DATA_FILE"
    return 1
  fi

  local any_pending=0

  while IFS= read -r line || [ -n "$line" ]; do
    # skip blank lines and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # assume "Name,status" format
    IFS=',' read -r student status <<< "$line"
    student="$(echo "$student" | xargs)"  # trim
    status="$(echo "$status" | tr '[:upper:]' '[:lower:]' | xargs)"

    if [[ "$status" == "pending" || "$status" == "not_submitted" ]]; then
      printf " - %s\n" "$student"
      any_pending=1
    fi
  done < "$DATA_FILE"

  return $any_pending
}
FUNCS

# Create scripts/reminder.sh
cat > "$main_dir/scripts/reminder.sh" <<'REM'
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
REM

# Create scripts/startup.sh
cat > "$main_dir/scripts/startup.sh" <<'STARTUP'
#!/usr/bin/env bash
# startup.sh
# Start the submission reminder application

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# make sure scripts are executable
find "$SCRIPT_DIR" -maxdepth 1 -type f -name "*.sh" -exec chmod +x {} \;

# run the reminder
bash "$SCRIPT_DIR/reminder.sh"
STARTUP

# Create data/submissions.txt with at least 5 additional records (total >= 5 extra)
cat > "$main_dir/data/submissions.txt" <<'DATA'
# Format: Name,status
Henry,submitted
David,pending
Chidi,submitted
Collins,pending
Michael Green,submitted
Afiti,pending
Albert,pending
Eric,submitted
Rapheal,pending
Success,submitted
DATA

# create a placeholder image (empty) so file is present
: > "$main_dir/image.png"

# Create a README inside the environment for quick use
cat > "$main_dir/README.md" <<'RMD'
# submission_reminder app (local copy)

To run the app:
1. cd into the scripts folder:
   cd scripts
2. make sure startup.sh is executable:
   chmod +x startup.sh
3. run:
   ./startup.sh

Configuration:
- config/config.env contains ASSIGNMENT, DEADLINE, and REMINDER_MESSAGE

Data:
- data/submissions.txt contains student records in format:
  Name,status  (status is 'submitted' or 'pending')
RMD

# Make all .sh files executable
chmod +x "$main_dir"/scripts/*.sh

echo ""
echo "Environment successfully created at: $main_dir"
echo "To run the app:"
echo "  cd $main_dir/scripts"
echo "  ./startup.sh"
