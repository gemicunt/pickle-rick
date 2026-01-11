#!/bin/bash

# -----------------------------------------------------------------------------
# Pickle Rick: Worker Session Bootstrapper (Morty)
# -----------------------------------------------------------------------------
# Initializes a worker session starting at the RESEARCH phase.
# -----------------------------------------------------------------------------

set -euo pipefail

# -- Configuration --
STATE_PATH="${PICKLE_STATE_FILE:-}"

if [[ -z "$STATE_PATH" ]]; then
  echo "❌ Error: PICKLE_STATE_FILE environment variable not set." >&2
  exit 1
fi

# -- State Variables --
TASK_STR="$*"

# -- Session Setup --
FULL_SESSION_PATH=$(dirname "$STATE_PATH")
mkdir -p "$FULL_SESSION_PATH"

# -- JSON Generation --
JSON_SAFE_PROMPT=$(echo "$TASK_STR" | sed 's/"/\\"/g')
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
START_EPOCH=$(date +%s)

# Initializing at 'research' phase
cat > "$STATE_PATH" <<JSON
{
  "active": true,
  "step": "research",
  "iteration": 1,
  "max_iterations": 10,
  "max_time_minutes": 20,
  "start_time_epoch": $START_EPOCH,
  "completion_promise": "I AM DONE",
  "original_prompt": "$JSON_SAFE_PROMPT",
  "current_ticket": null,
  "worker": true,
  "history": [],
  "started_at": "$TIMESTAMP",
  "session_dir": "$FULL_SESSION_PATH"
}
JSON

# -- User Output --

cat <<EOF
🥒 Pickle Worker (Morty) Activated!

>> Mode:      Execution (Research -> Plan -> Implement -> Refactor)
>> State:     $STATE_PATH
>> Task:      $TASK_STR

⚠️  WARNING: Morty will work until the task is complete or he expires.
EOF
