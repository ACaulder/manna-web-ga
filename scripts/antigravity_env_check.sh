#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE_ROOT="${HOME}/ANTIGRAVITY_SANDBOX"

FAIL=0
WARN=0

say() { printf '%s\n' "$*"; }
hr() { printf '\n--------------------------------------------------------------------------------\n'; }

hr
say "Google Antigravity — Environment Check (read-only)"
say "Repo: $HERE"
say "Workspace root: $WORKSPACE_ROOT"
hr

# 0) Workspace boundary (hard fail)
if [[ "$HERE" != "$WORKSPACE_ROOT"/* ]]; then
  say "FAIL: repo is not located under workspace root"
  say "  repo=$HERE"
  say "  workspace=$WORKSPACE_ROOT"
  FAIL=1
fi

# 1) Forbidden path references (runtime code only)
say "Check: forbidden path references (runtime code only)"
if command -v rg >/dev/null 2>&1; then
  # NOTE: This intentionally excludes scripts/ and docs/ to avoid self-referential failures.
  #       Boundary/requirements docs may mention forbidden paths as examples.
  FORBIDDEN=(
    "$HOME/SANDBOX"
    "/Users/andrewcaulder/SANDBOX"
    "/Library/Mobile Documents/"
    "/Library/CloudStorage/"
  )

  for P in "${FORBIDDEN[@]}"; do
    if rg -n --fixed-strings "$P" . \
      --glob '!.git/**' \
      --glob '!node_modules/**' \
      --glob '!.vercel/**' \
      --glob '!.svelte-kit/**' \
      --glob '!scripts/**' \
      --glob '!docs/**' \
      --glob '!SECURITY_BOUNDARIES.md' \
      >/dev/null 2>&1; then
      say "FAIL: Found forbidden path reference: $P"
      rg -n --fixed-strings "$P" . \
        --glob '!.git/**' \
        --glob '!node_modules/**' \
        --glob '!.vercel/**' \
        --glob '!.svelte-kit/**' \
        --glob '!scripts/**' \
        --glob '!docs/**' \
        --glob '!SECURITY_BOUNDARIES.md' \
        | sed -n '1,120p'
      FAIL=1
    fi
  done
else
  say "NOTE: rg not found; cannot scan forbidden paths."
  WARN=1
fi

# 2) .env files present (hard fail)
say "Check: .env files present"
if find "$HERE" \
  -type f \( -name ".env" -o -name ".env.*" \) \
  ! -name ".env.example" ! -name ".env.template" \
  -print 2>/dev/null | rg -q .; then
  say "FAIL: .env file(s) present"
  find "$HERE" \
    -type f \( -name ".env" -o -name ".env.*" \) \
    ! -name ".env.example" ! -name ".env.template" \
    -print 2>/dev/null | sed -n '1,120p'
  FAIL=1
else
  say "OK: no .env files found"
fi

# 3) Symlinks escaping workspace root (hard fail)
say "Check: symlinks escaping workspace root"
FOUND=0
while IFS= read -r REL; do
  [ -n "${REL:-}" ] || continue
  L="$HERE/$REL"
  [ -L "$L" ] || continue

  TARGET="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$L")"
  if [[ "$TARGET" != "$WORKSPACE_ROOT"* ]]; then
    if [ "$FOUND" -eq 0 ]; then
      say "FAIL: symlink(s) escape workspace root"
      FOUND=1
    fi
    echo "$L -> $TARGET"
  fi
done < <(git -C "$HERE" ls-files -s | awk '$1 ~ /^120000$/ {print $4}')

if [ "$FOUND" -eq 0 ]; then
  say "OK: no git-tracked symlinks"
else
  FAIL=1
fi

# 4) git status (warn only)
say "Check: git status"
if git -C "$HERE" status --porcelain | rg -q . 2>/dev/null; then
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
