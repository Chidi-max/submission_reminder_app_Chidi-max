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
