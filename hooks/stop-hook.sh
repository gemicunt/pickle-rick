#!/bin/bash

# Stop Hook for Pickle Rick
# Intercepts exit attempts to maintain the iterative loop

set -euo pipefail

EXTENSION_DIR="$HOME/.gemini/extensions/pickle-rick"
STATE_FILE="$EXTENSION_DIR/state.json"

# 1. Read Hook Input (JSON from stdin)
INPUT_JSON=$(cat)

# 2. Check if loop is active
if [[ ! -f "$STATE_FILE" ]]; then
  # No state file -> Allow exit
  echo '{"action": "exit"}'
  exit 0
fi

# 3. Read State using jq
ACTIVE=$(jq -r '.active // false' "$STATE_FILE" 2>/dev/null || echo "false")

if [[ "$ACTIVE" != "true" ]]; then
  # Not active -> Allow exit
  echo '{"action": "exit"}'
  exit 0
fi

# 4. Parse Loop State
ITERATION=$(jq -r '.iteration // 1' "$STATE_FILE")
MAX_ITERATIONS=$(jq -r '.max_iterations // 0' "$STATE_FILE")
COMPLETION_PROMISE=$(jq -r '.completion_promise // "null"' "$STATE_FILE")
ORIGINAL_PROMPT=$(jq -r '.original_prompt' "$STATE_FILE")

# 5. Check Termination Conditions

# 5a. Max Iterations
if [[ "$MAX_ITERATIONS" -gt 0 ]] && [[ "$ITERATION" -ge "$MAX_ITERATIONS" ]]; then
  # Limit reached -> Allow exit
  # Disable loop
  TMP_STATE=$(mktemp)
  jq '.active = false' "$STATE_FILE" > "$TMP_STATE" && mv "$TMP_STATE" "$STATE_FILE"
  echo '{"action": "exit"}'
  exit 0
fi

# 5b. Completion Promise
# Extract the last assistant message from the input transcript
# The input JSON has "transcript": [...]
# We filter for role "model" (Gemini)
LAST_MESSAGE=$(echo "$INPUT_JSON" | jq -r '.transcript | map(select(.role=="model")) | last | .content // ""')

if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ "$COMPLETION_PROMISE" != "" ]]; then
  if echo "$LAST_MESSAGE" | grep -q "<promise>$COMPLETION_PROMISE</promise>"; then
    # Promise fulfilled -> Allow exit
    # Disable loop
    TMP_STATE=$(mktemp)
    jq '.active = false' "$STATE_FILE" > "$TMP_STATE" && mv "$TMP_STATE" "$STATE_FILE"
    echo '{"action": "exit"}'
    exit 0
  fi
fi

# 6. Continue Loop (Prevent Exit)

# Increment iteration
NEXT_ITERATION=$((ITERATION + 1))
TMP_STATE=$(mktemp)
jq --argjson iter "$NEXT_ITERATION" '.iteration = $iter' "$STATE_FILE" > "$TMP_STATE" && mv "$TMP_STATE" "$STATE_FILE"

# Construct Feedback Message
FEEDBACK="🥒 **Pickle Rick Loop Active** (Iteration $NEXT_ITERATION)"
if [[ "$MAX_ITERATIONS" -gt 0 ]]; then
  FEEDBACK="$FEEDBACK of $MAX_ITERATIONS"
fi

# Output JSON to prevent exit and send new prompt
jq -n \
  --arg prompt "$ORIGINAL_PROMPT" \
  --arg feedback "$FEEDBACK" \
  '{ 
    action: "continue",
    user_message: $prompt,
    system_message: $feedback
  }'
