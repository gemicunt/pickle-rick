#!/bin/bash

# -----------------------------------------------------------------------------
# Pickle Rick: Session Bootstrapper
# -----------------------------------------------------------------------------
# Initializes the recursive development environment.
# -----------------------------------------------------------------------------

set -euo pipefail

# -- Configuration --
ROOT_DIR="$HOME/.gemini/extensions/pickle-rick"
SESSIONS_ROOT="$ROOT_DIR/sessions"
LATEST_LINK="$ROOT_DIR/current_session_path"

# -- State Variables --
LOOP_LIMIT=0
PROMISE_TOKEN="null"
TASK_ARGS=()

# -- Helpers --

die() {
  echo "❌ Error: $1" >&2
  exit 1
}

# -- Argument Parser --

while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-iterations)
      [[ "${2:-}" =~ ^[0-9]+$ ]] || die "Invalid iteration limit: '${2:-}'"
      LOOP_LIMIT="$2"
      shift 2
      ;;
    --completion-promise)
      [[ -n "${2:-}" ]] || die "Missing promise text."
      PROMISE_TOKEN="$2"
      shift 2
      ;;
    *)
      TASK_ARGS+=("$1")
      shift
      ;;
  esac
done
TASK_STR="${TASK_ARGS[*]}"
[[ -n "$TASK_STR" ]] || die "No task specified. Run /pickle --help for usage."

# -- Session Setup --

# Slugify: lowercase -> alphanumeric/hyphen only -> trim
SESSION_SLUG=$(echo "$TASK_STR" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-|-$//g' | cut -c 1-30)
TODAY=$(date +%Y-%m-%d)
SESSION_ID="${TODAY}-${SESSION_SLUG}"

FULL_SESSION_PATH="$SESSIONS_ROOT/$SESSION_ID"
STATE_PATH="$FULL_SESSION_PATH/state.json"

mkdir -p "$FULL_SESSION_PATH"
echo "$FULL_SESSION_PATH" > "$LATEST_LINK"

# -- JSON Generation --

# Handle JSON string escaping
JSON_SAFE_PROMPT=$(echo "$TASK_STR" | sed 's/"/\\"/g')
JSON_SAFE_PROMISE=$( [[ "$PROMISE_TOKEN" == "null" ]] && echo "null" || echo "\"$PROMISE_TOKEN\"" )
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

cat > "$STATE_PATH" <<JSON
{
  "active": true,
  "step": "prd",
  "iteration": 1,
  "max_iterations": $LOOP_LIMIT,
  "completion_promise": $JSON_SAFE_PROMISE,
  "original_prompt": "$JSON_SAFE_PROMPT",
  "current_ticket": null,
  "history": [],
  "started_at": "$TIMESTAMP",
  "session_dir": "$FULL_SESSION_PATH"
}
JSON

# -- User Output --

cat <<EOF
🥒 Pickle Rick Activated!.

>> Loop Config:
   Iteration: 1
   Limit:     $( [[ $LOOP_LIMIT -gt 0 ]] && echo "$LOOP_LIMIT" || echo "∞" )
   Promise:   $( [[ "$PROMISE_TOKEN" != "null" ]] && echo "$PROMISE_TOKEN" || echo "None" )

>> Workspace:
   Path:      $FULL_SESSION_PATH
   State:     $STATE_PATH

>> Directive:
   $TASK_STR
EOF

if [[ "$PROMISE_TOKEN" != "null" ]]; then
  echo ""
  echo "⚠️  STRICT EXIT CONDITION ACTIVE"
  echo "   You must output: <promise>$PROMISE_TOKEN</promise>"
fi