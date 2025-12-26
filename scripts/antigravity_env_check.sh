#!/usr/bin/env bash
set -euo pipefail

# --- CI-safe rg fallback (GitHub runners may not have ripgrep) ---
if ! command -v rg >/dev/null 2>&1; then
  rg() {
    # Minimal ripgrep-compatible fallback used by CI.
    # Ignores rg-specific flags and prunes heavy dirs.
    local pattern="" path="."
    while [ "$#" -gt 0 ]; do
      case "$1" in
        --glob|-g|--iglob) shift ;;               # ignore glob + its argument
        -n|--no-messages|--hidden|-S|--smart-case) ;;
        --*) ;;                                   # ignore other long flags
        -*) ;;                                    # ignore other short flags
        *)
          if [ -z "$pattern" ]; then
            pattern="$1"
          else
            path="$1"
          fi
          ;;
      esac
      shift
    done

    [ -n "$pattern" ] || return 2

    # prune dirs we never want in this check
    find "$path" \
      \( -path "$path/docs" -o -path "$path/docs/*" \
         -o -path "$path/scripts" -o -path "$path/scripts/*" \
         -o -path "$path/node_modules" -o -path "$path/node_modules/*" \
         -o -path "$path/.svelte-kit" -o -path "$path/.svelte-kit/*" \
         -o -path "$path/.git" -o -path "$path/.git/*" \) -prune -false -o \
      -type f -print0 \
      | xargs -0 grep -nH -- "$pattern" 2>/dev/null || true
  }
fi


PASS=0; WARN=0; FAIL=0

say(){ printf '%s\n' "$*"; }
hr(){ printf '%s\n' "--------------------------------------------------------------------------------"; }
pass(){ PASS=$((PASS+1)); say "PASS: $*"; }
warn(){ WARN=$((WARN+1)); say "WARN: $*"; }
fail(){ FAIL=$((FAIL+1)); say "FAIL: $*"; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
WORKSPACE_ROOT="$(cd "$REPO_ROOT/.." && pwd -P)"

hr
say "Google Antigravity — Environment Check (read-only)"
say "Repo: $REPO_ROOT"
say "Workspace root: $WORKSPACE_ROOT"
hr
say

# 1) Forbidden absolute host paths — runtime only (NOT docs/, NOT scripts/)
say "Check: forbidden path references (runtime source/config only; excludes docs/ and scripts/)"
FORBIDDEN_RE='(/Users/[^/]+/|/home/[^/]+/|C:\\Users\\[^\\]+\\)'

if command -v rg >/dev/null 2>&1; then
  if git -C "$REPO_ROOT" ls-files -z -- \
      'src/**' 'static/**' \
      'package.json' 'package-lock.json' \
      'svelte.config.*' 'vite.config.*' 'tsconfig*.json' \
    | xargs -0 rg -n "$FORBIDDEN_RE" --; then
    fail "Found forbidden absolute host-path references in runtime source/config files"
  else
    pass "No forbidden absolute host-path references found (runtime only)"
  fi
else
  fail "ripgrep (rg) not found; install it (brew install ripgrep) or add a grep fallback"
fi

say

# 2) .env presence
say "Check: .env files present"
if find "$REPO_ROOT" -maxdepth 2 -name ".env*" -print -quit | grep -q .; then
  fail "Found .env* files (do not commit secrets; use CI/env vars)"
else
  pass "No .env* files found"
fi

say

# 3) Symlinks escaping workspace root (git-tracked only)
say "Check: symlinks escaping workspace root (git-tracked only)"
FOUND_SYMLINK=0
BAD_SYMLINK=0

while IFS= read -r -d '' f; do
  path="$REPO_ROOT/$f"
  if [ -L "$path" ]; then
    FOUND_SYMLINK=1
    real="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$path")"
    case "$real" in
      "$WORKSPACE_ROOT"/*) : ;;
      *) BAD_SYMLINK=1; say "  BAD: $f -> $real" ;;
    esac
  fi
done < <(git -C "$REPO_ROOT" ls-files -z)

if [ "$FOUND_SYMLINK" -eq 0 ]; then
  pass "No git-tracked symlinks found"
elif [ "$BAD_SYMLINK" -eq 0 ]; then
  pass "Git-tracked symlinks are contained inside workspace root"
else
  fail "Found git-tracked symlinks escaping workspace root"
fi

say

# 4) Git status (informational)
say "Check: git status"
if git -C "$REPO_ROOT" diff --quiet && git -C "$REPO_ROOT" diff --cached --quiet; then
  pass "Working tree clean"
else
  warn "Working tree dirty (not a security failure, but be intentional)"
fi

say
hr
say "Result:"
say "  PASS=$PASS"
say "  WARN=$WARN"
say "  FAIL=$FAIL"
hr

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
