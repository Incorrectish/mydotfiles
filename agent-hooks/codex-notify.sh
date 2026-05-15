#!/usr/bin/env bash
# Codex CLI hook adapter → /api/notify on stoic-game's local server.
#
# Wired via ~/.codex/config.toml:
#   notify = ["bash", "/abs/path/to/agent-hooks/codex-notify.sh"]
# Codex invokes the script with $1 = event name (agent-turn-complete,
# session-start, error, permission*, …) and sets CODEX_SESSION_ID +
# PWD in the environment.
#
# Title shape:
#   codex:<git-branch-or-cwd-basename>:<sha256(session_id)[:4]>
#
# The server's autopick hashes the title to a sound so the same Codex
# session plays the same chime across all events.

set -uo pipefail

EVENT="${1:-event}"
SESSION_ID="${CODEX_SESSION_ID:-}"
CWD="${PWD:-$(pwd)}"

BRANCH=""
if branch=$(git -C "$CWD" branch --show-current 2>/dev/null) && [ -n "$branch" ]; then
  BRANCH=$branch
else
  BRANCH=$(basename "$CWD")
fi

if [ -n "$SESSION_ID" ]; then
  HASH=$(printf '%s' "$SESSION_ID" | shasum -a 256 2>/dev/null | cut -c1-4)
else
  HASH="????"
fi

TITLE="codex:${BRANCH}:${HASH}"
case "$EVENT" in
  agent-turn-complete|complete|done) MSG="turn done" ;;
  start|session-start)               MSG="session start" ;;
  error|fail*)                       MSG="error" ;;
  permission*|approve*)              MSG="needs approval" ;;
  *)                                  MSG="$EVENT" ;;
esac

BODY=$(python3 - "$TITLE" "$MSG" <<'PY'
import json, sys
print(json.dumps({"title": sys.argv[1], "message": sys.argv[2]}))
PY
)

curl -sf -m 2 -X POST \
  -H 'Content-Type: application/json' \
  -d "$BODY" \
  http://127.0.0.1:8765/api/notify >/dev/null 2>&1 &
disown 2>/dev/null || true

exit 0
