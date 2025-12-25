#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-$HOME/ANTIGRAVITY_SANDBOX}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

say(){ printf "%s\n" "$*"; }
hr(){ say "--------------------------------------------------------------------------------"; }

fail=0
warn=0

hr
say "Google Antigravity — Environment Check (read-only)"
say "Repo: $REPO"
say "Workspace root: $ROOT"
hr

# Guard: repo must be under workspace root
case "$REPO" in
  "$ROOT"/*) ;;
  *)
    say "FAIL: Repo is not under workspace root."
    say "  repo: $REPO"
    say "  root: $ROOT"
    exit 2
    ;;
esac

# Check: forbidden path references
FORBIDDEN=(
  "$HOME/Library/Mobile Documents/"
  "$HOME/Library/CloudStorage/"
  "$HOME/MANNA/"
  "/Library/Mobile Documents/"
  "/Library/CloudStorage/"
)

say "Check: forbidden path references"
if command -v rg >/dev/null 2>&1; then
  for p in "${FORBIDDEN[@]}"; do
    if rg --fixed-strings -n "$p" "$REPO" \
      --glob '!**/node_modules/**' \
      --glob '!**/.git/**' >/dev/null 2>&1; then
      say "FAIL: Found forbidden path reference: $p"
      rg --fixed-strings -n "$p" "$REPO" \
        --glob '!**/node_modules/**' \
        --glob '!**/.git/**' | head -n 50 || true
      fail=1
    fi
  done
else
  say "WARN: ripgrep (rg) not found; skipping forbidden path scan."
  warn=1
fi

# Check: .env files (excluding node_modules)
say "Check: .env files present"
ENV_HITS="$(find "$REPO" -type f \( -name ".env" -o -name ".env.*" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null || true)"
if [ -n "${ENV_HITS:-}" ]; then
  say "FAIL: .env-style files found:"
  printf "%s\n" "$ENV_HITS"
  fail=1
else
  say "OK: no .env files found"
fi

# Check: symlinks that escape workspace root
say "Check: symlinks escaping workspace root"
if command -v python3 >/dev/null 2>&1; then
  python3 - <<'PY' "$REPO" "$ROOT"
import os, sys
repo, root = sys.argv[1], sys.argv[2]
bad = []
for dirpath, _, filenames in os.walk(repo):
  for name in filenames:
    p = os.path.join(dirpath, name)
    if os.path.islink(p):
      target = os.path.realpath(p)
      if not target.startswith(root + os.sep):
        bad.append((p, target))
if bad:
  print("FAIL: symlinks escape workspace root:")
  for p,t in bad[:50]:
    print(f"  {p} -> {t}")
  sys.exit(1)
print("OK: no escaping symlinks")
PY
else
  say "WARN: python3 not found; skipping symlink resolution check."
  warn=1
fi

# Check: git cleanliness (informational)
if [ -d "$REPO/.git" ]; then
  say "Check: git status"
  if git -C "$REPO" diff --quiet && git -C "$REPO" diff --cached --quiet; then
    say "OK: working tree clean"
  else
    say "WARN: working tree has changes"
    warn=1
  fi
else
  say "WARN: not a git repo"
  warn=1
fi

hr
say "Result:"
say "  FAIL=$fail"
say "  WARN=$warn"
hr

if [ "$fail" -ne 0 ]; then exit 2; fi
if [ "$warn" -ne 0 ]; then exit 1; fi
exit 0
