#!/usr/bin/env bash
# Claude Code hook adapter → /api/notify on stoic-game's local server.
#
# Reads the hook payload as JSON on stdin (per Claude Code's hook
# protocol), builds a session-stable title of the form
#   claude:<git-branch-or-cwd-basename>:<sha256(session_id)[:4]>
# and POSTs to http://127.0.0.1:8765/api/notify. The server's autopick
# hashes the title to a sound, so the same Claude session always plays
# the same chime, and concurrent sessions on the same branch get
# different chimes via the session-hash suffix.
#
# Fire-and-forget: silent fail if the server is down.

set -uo pipefail

PAYLOAD=$(cat 2>/dev/null || true)

parse() {
  python3 - <<'PY' "$PAYLOAD" "$1" 2>/dev/null
import json, sys
try:
    d = json.loads(sys.argv[1]) if sys.argv[1] else {}
    print(d.get(sys.argv[2], ''))
except Exception:
    pass
PY
}

EVENT=$(parse hook_event_name)
SESSION_ID=$(parse session_id)
CWD=$(parse cwd)
[ -z "$CWD" ] && CWD="$PWD"
NOTIF_MSG=$(parse message)

# Branch name when in a git checkout, else basename of cwd. Detached-
# HEAD case (--show-current empty) also falls back to basename.
# Generic trunk names (main / master / main-thru) don't distinguish
# repos — fall back to the dir basename in those cases so two
# "main" sessions in different projects get different titles and
# therefore different hash-picked chimes.
BRANCH=""
if branch=$(git -C "$CWD" branch --show-current 2>/dev/null) && [ -n "$branch" ]; then
  case "$branch" in
    main|master|main-thru) BRANCH=$(basename "$CWD") ;;
    *)                     BRANCH=$branch ;;
  esac
else
  BRANCH=$(basename "$CWD")
fi

# First 4 hex of sha256(session_id) — distinguishes concurrent sessions
# in the same branch. Stable across all events of a single session.
if [ -n "$SESSION_ID" ]; then
  HASH=$(printf '%s' "$SESSION_ID" | shasum -a 256 2>/dev/null | cut -c1-4)
else
  HASH="????"
fi

TITLE="claude:${BRANCH}:${HASH}"
case "$EVENT" in
  Stop)              MSG="turn done" ;;
  Notification)      MSG="${NOTIF_MSG:-needs attention}" ;;
  PreCompact)        MSG="compacting context" ;;
  SubagentStart)     MSG="subagent started" ;;
  *)                 MSG="${EVENT:-event}" ;;
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
