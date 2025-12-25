#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

hr() { printf "\n--------------------------------------------------------------------------------\n"; }
say() { printf "%s\n" "$*"; }

FAIL=0
WARN=0

if ! command -v rg >/dev/null 2>&1; then
  echo "ERROR: ripgrep (rg) is required. Install via: brew install ripgrep"
  exit 2
fi

hr
say "Google Antigravity — Environment Check (read-only)"
say "Repo: $HERE"
say "Workspace root: $ROOT"
hr

# Only enforce boundaries on runtime code, not docs / boundary docs / the checker itself
RG_EXCLUDES=(
  --glob '!**/.git/**'
  --glob '!**/node_modules/**'
  --glob '!**/.svelte-kit/**'
  --glob '!**/dist/**'
  --glob '!**/build/**'
  --glob '!docs/**'
  --glob '!SECURITY_BOUNDARIES.md'
  --glob '!scripts/antigravity_env_check.sh'
)

# Forbidden locations: Google Antigravity must NOT hardcode paths into iCloud/Drive/MANNA/etc.
# (Docs may mention them; runtime code may not.)
FORBIDDEN_REGEX=(
  '/Users/[^/]+/Library/Mobile Documents/'
  '/Users/[^/]+/Library/CloudStorage/'
  '\$HOME/Library/Mobile Documents/'
  '\$HOME/Library/CloudStorage/'
  '~/Library/Mobile Documents/'
  '~/Library/CloudStorage/'
  '/Library/Mobile Documents/'
  '/Library/CloudStorage/'
  '/MasterVault/'
  '/MANNA/'
)

say "Check: forbidden path references (runtime code only)"
for pat in "${FORBIDDEN_REGEX[@]}"; do
  if rg -n "${RG_EXCLUDES[@]}" --hidden --no-ignore-vcs --pcre2 "$pat" "$HERE" >/tmp/antigravity_forbidden_hits.txt 2>/dev/null; then
    say "FAIL: Found forbidden path reference pattern: $pat"
    sed -n '1,120p' /tmp/antigravity_forbidden_hits.txt
    FAIL=1
  fi
done

say "Check: .env files present"
if find "$HERE" -maxdepth 6 -type f \( -name ".env" -o -name ".env.*" \) | rg -q .; then
  say "FAIL: .env-style files found (do not keep secrets in repo)."
  find "$HERE" -maxdepth 6 -type f \( -name ".env" -o -name ".env.*" \) -print | sed -n '1,120p'
  FAIL=1
else
  say "OK: no .env files found"
fi

say "Check: symlinks escaping workspace root"
if find "$HERE" -type l -print0 | while IFS= read -r -d '' L; do
     T="$(python3 - <<PY
import os,sys
print(os.path.realpath(sys.argv[1]))
PY
"$L")"
     case "$T" in
       "$ROOT"/*) ;;
       *) echo "$L -> $T"; exit 10 ;;
     esac
   done; then
  say "OK: no escaping symlinks"
else
  say "FAIL: symlink(s) escape workspace root"
  FAIL=1
fi

say "Check: git status"
if git -C "$HERE" status --porcelain | rg -q .; then
  say "WARN: working tree dirty (not a security failure, but be intentional)"
  git -C "$HERE" status --porcelain | sed -n '1,120p'
  WARN=1
else
  say "OK: working tree clean"
fi

hr
say "Result:"
say "  FAIL=$FAIL"
say "  WARN=$WARN"
hr

if [ "$FAIL" -ne 0 ]; then exit 2; fi
if [ "$WARN" -ne 0 ]; then exit 1; fi
exit 0
