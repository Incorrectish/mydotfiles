#!/usr/bin/env bash
# Agent-notification installer. Wires Claude Code + Codex CLI hooks
# to fire curl → http://127.0.0.1:8765/api/notify (provided by whatever
# is running on that port — currently the stoic-game server, but this
# installer doesn't know or care).
#
# Lives in ~/.config alongside the adapter scripts so the whole bundle
# is tracked in the dotfiles repo. On a new machine: clone dotfiles,
# bash install.sh, done.
#
# Usage:
#   bash install.sh           # apply
#   bash install.sh --check   # dry-run; print what would change
#
# Idempotent. Re-running updates paths if you moved this dir.

set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOOK="$SELF_DIR/agent-hooks/claude-notify.sh"
CODEX_HOOK="$SELF_DIR/agent-hooks/codex-notify.sh"

DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --check|--dry-run|-n) DRY_RUN=true ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) printf 'unknown arg: %s\n' "$arg" >&2; exit 2 ;;
  esac
done

say()  { printf '%s\n' "$*"; }
real() {
  # Run side-effectful command unless --check is on. Returns 0 on
  # dry-run so call sites can chain "real ... && say 'made: ...'".
  if $DRY_RUN; then say "[dry-run] would: $*"; return 1; else "$@"; fi
}

# ─── 1. ~/.config/{claude,codex}.config symlinks ────────────────
# So the agent config dirs are reachable from XDG-land for editing /
# poking, while the apps keep reading from ~/.claude and ~/.codex.

mkdir -p "$HOME/.config"
for app in claude codex; do
  realsrc="$HOME/.${app}"
  dst="$HOME/.config/${app}.config"
  if [ ! -e "$realsrc" ]; then
    say "skip: $realsrc does not exist (install $app first?)"
    continue
  fi
  if [ -L "$dst" ]; then
    cur=$(readlink "$dst")
    if [ "$cur" = "$realsrc" ]; then
      say "ok:   $dst → $realsrc"
    else
      say "WARN: $dst is a symlink to $cur (expected $realsrc); leaving alone"
    fi
  elif [ -e "$dst" ]; then
    say "WARN: $dst exists and is not a symlink; leaving alone"
  else
    real ln -s "$realsrc" "$dst" && say "made: $dst → $realsrc"
  fi
done

# ─── 2. chmod +x on the adapter scripts ─────────────────────────

for f in "$CLAUDE_HOOK" "$CODEX_HOOK"; do
  if [ -f "$f" ] && [ ! -x "$f" ]; then
    real chmod +x "$f" && say "chmod +x $f"
  fi
done

# ─── 3. Rewrite Claude Code hook entries ────────────────────────
# 4 events fire the adapter; 5 stubbed with "true" so they're easy
# to re-enable (just swap "true" for the adapter path later). All
# other top-level keys in settings.json (theme, enabledPlugins, …)
# preserved verbatim by editing the dict in place.

CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [ -f "$CLAUDE_SETTINGS" ]; then
  if $DRY_RUN; then
    say "[dry-run] would back up + rewrite hooks in $CLAUDE_SETTINGS"
  else
    cp "$CLAUDE_SETTINGS" "${CLAUDE_SETTINGS}.bak"
    python3 - "$CLAUDE_SETTINGS" "$CLAUDE_HOOK" <<'PY'
import json, sys
path, adapter = sys.argv[1], sys.argv[2]
with open(path) as f: cfg = json.load(f)
LIVE = ("Stop", "Notification", "PreCompact", "SubagentStart")
STUB = ("SessionStart", "SessionEnd", "UserPromptSubmit",
        "PermissionRequest", "PostToolUseFailure")
hooks = cfg.setdefault("hooks", {})
for ev in LIVE:
    hooks[ev] = [{"matcher": "", "hooks": [
        {"type": "command", "command": adapter, "timeout": 5, "async": True}
    ]}]
for ev in STUB:
    hooks[ev] = [{"matcher": "", "hooks": [
        {"type": "command", "command": "true", "timeout": 1, "async": True}
    ]}]
with open(path, "w") as f:
    json.dump(cfg, f, indent=2); f.write("\n")
print(f"updated {path} (backup: {path}.bak)")
PY
  fi
else
  say "skip: $CLAUDE_SETTINGS not present"
fi

# ─── 4. Codex notify line ───────────────────────────────────────

CODEX_CONFIG="$HOME/.codex/config.toml"
if [ -f "$CODEX_CONFIG" ]; then
  WANT_LINE="notify = [\"bash\", \"$CODEX_HOOK\"]"
  if grep -qE '^notify[[:space:]]*=' "$CODEX_CONFIG"; then
    CURRENT=$(grep -E '^notify[[:space:]]*=' "$CODEX_CONFIG" | head -1)
    if [ "$CURRENT" = "$WANT_LINE" ]; then
      say "ok:   $CODEX_CONFIG notify line already correct"
    elif $DRY_RUN; then
      say "[dry-run] would replace: $CURRENT"
      say "[dry-run]            with: $WANT_LINE"
    else
      python3 - "$CODEX_CONFIG" "$WANT_LINE" <<'PY'
import re, sys
path, want = sys.argv[1], sys.argv[2]
with open(path) as f: text = f.read()
new = re.sub(r'(?m)^notify\s*=.*$', want, text)
with open(path, 'w') as f: f.write(new)
print(f"replaced notify line in {path}")
PY
    fi
  elif $DRY_RUN; then
    say "[dry-run] would append to $CODEX_CONFIG: $WANT_LINE"
  else
    [ -z "$(tail -c1 "$CODEX_CONFIG")" ] || printf '\n' >> "$CODEX_CONFIG"
    printf '%s\n' "$WANT_LINE" >> "$CODEX_CONFIG"
    say "appended notify line to $CODEX_CONFIG"
  fi
else
  say "skip: $CODEX_CONFIG not present"
fi

say
say "Done. Notifications will hit whatever is listening on port 8765."
say "Restart any open Claude Code / Codex sessions to pick up the new hooks."
