#!/usr/bin/env bash
# Codex CLI hook adapter → /api/notify on stoic-game's local server.
#
# Wired via ~/.codex/config.toml:
#   notify = ["bash", "/abs/path/to/agent-hooks/codex-notify.sh"]
# Codex invokes the script with a SINGLE argument: a JSON object
# describing the event. Shape (current Codex):
#   {"type":"agent-turn-complete","thread-id":"...","turn-id":"...",
#    "cwd":"...","client":"codex-tui",
#    "input-messages":[...full chat history, can be 30KB+...],
#    "last-assistant-message":"..."}
# We extract only the small fields (type, thread-id, cwd) and drop
# everything else on the floor — the agent's already shown its output
# in the terminal; the ping just needs to say "something happened."
#
# Title shape:
#   codex:<git-branch-or-cwd-basename>:<sha256(thread-id)[:4]>

set -uo pipefail

PAYLOAD="${1:-}"

parse() {
  python3 - <<'PY' "$PAYLOAD" "$1" 2>/dev/null
import json, sys
try:
    d = json.loads(sys.argv[1]) if sys.argv[1] else {}
    v = d.get(sys.argv[2], '')
    print(v if isinstance(v, str) else json.dumps(v))
except Exception:
    pass
PY
}

TYPE=$(parse type)
SESSION_ID=$(parse thread-id)
PAYLOAD_CWD=$(parse cwd)
CWD="${PAYLOAD_CWD:-${PWD:-$(pwd)}}"

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
case "$TYPE" in
  agent-turn-complete|complete|done) MSG="turn done" ;;
  start|session-start)               MSG="session start" ;;
  error|fail*)                       MSG="error" ;;
  permission*|approve*)              MSG="needs approval" ;;
  '')                                 MSG="event" ;;
  *)                                  MSG="$TYPE" ;;
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
