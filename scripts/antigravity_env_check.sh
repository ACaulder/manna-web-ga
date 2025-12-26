#!/usr/bin/env bash
set -euo pipefail

PASS=0
WARN=0
FAIL=0

pass(){ echo "PASS: $*"; PASS=$((PASS+1)); }
warn(){ echo "WARN: $*"; WARN=$((WARN+1)); }
fail(){ echo "FAIL: $*"; FAIL=$((FAIL+1)); }

<<<<<<< HEAD
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$HERE"
WORKSPACE_ROOT="$(cd "$REPO_ROOT/.." && pwd)"
=======
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
WORKSPACE_ROOT="$(cd .. && pwd)"
>>>>>>> a359902 (fix(antigravity): make env check portable; scan runtime only)

echo
echo "--------------------------------------------------------------------------------"
echo "Google Antigravity — Environment Check (read-only)"
echo "Repo: $REPO_ROOT"
echo "Workspace root: $WORKSPACE_ROOT"
echo "--------------------------------------------------------------------------------"
echo

# --- Ticket 2: forbidden paths are referenced anywhere in repo text files ---
# Pragmatic definition: no absolute host home-directory paths should be committed.
# (macOS/Linux/Windows). Keep docs conceptual; don’t embed literal /Users/... examples.
echo "Check: forbidden path references (repo text files)"

<<<<<<< HEAD
SEARCH_TOOL="grep"
if command -v rg >/dev/null 2>&1; then
  SEARCH_TOOL="rg"
fi

# Exclude build junk and self (the checker contains patterns)
EXCLUDES=(
  "--glob" "!.git/**"
  "--glob" "!node_modules/**"
  "--glob" "!.svelte-kit/**"
  "--glob" "!.vercel/**"
  "--glob" "!dist/**"
  "--glob" "!build/**"
  "--glob" "!coverage/**"
  "--glob" "!.next/**"
  "--glob" "!.cache/**"
  "--glob" "!scripts/antigravity_env_check.sh"
)
=======
# ---------------------------
# Check 1: forbidden path references (runtime only)
# Exclude docs/ and scripts/ so the checker doesn't self-trigger.
# Only scan git-tracked files to avoid node_modules/.svelte-kit artifacts in CI.
say "Check: forbidden path references (runtime source/config only; excludes docs/ and scripts/)"

RUNTIME_FILES=()
if command -v rg >/dev/null 2>&1; then
  while IFS= read -r f; do
    [ -n "$f" ] && RUNTIME_FILES+=("$f")
  done < <(
    git ls-files \
      | rg -v '^(docs/|scripts/|\.github/)' \
      | rg -v '\.md$' \
      | rg -e '\.(svelte|ts|js|mjs|cjs|json|ya?ml|toml)$' \
      || true
  )
else
  while IFS= read -r f; do
    [ -n "$f" ] && RUNTIME_FILES+=("$f")
  done < <(
    git ls-files \
      | grep -vE '^(docs/|scripts/|\.github/)' \
      | grep -vE '\.md$' \
      | grep -E '\.(svelte|ts|js|mjs|cjs|json|yaml|yml|toml)$' \
      || true
  )
fi
>>>>>>> a359902 (fix(antigravity): make env check portable; scan runtime only)

# Regex matches absolute home roots:
#   /Users/<name>/...
#   /home/<name>/...
#   C:\Users\<name>\...
FORBIDDEN_RE='(/Users/[^/]+/|/home/[^/]+/|C:\\\\Users\\\\[^\\\\]+\\\\)'

if [ "$SEARCH_TOOL" = "rg" ]; then
  if rg -n --hidden --no-ignore --pcre2 "${EXCLUDES[@]}" -S -e "$FORBIDDEN_RE" "$REPO_ROOT" >/dev/null 2>&1; then
    echo "Matches:"
    rg -n --hidden --no-ignore --pcre2 "${EXCLUDES[@]}" -S -e "$FORBIDDEN_RE" "$REPO_ROOT" | head -n 50
    fail "Found forbidden absolute host-path references in repo text files"
  else
    pass "No forbidden absolute host-path references found"
  fi
else
<<<<<<< HEAD
  # grep fallback (best-effort). -I ignores binaries.
  if grep -RInI -E --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.svelte-kit --exclude-dir=.vercel \
      --exclude-dir=dist --exclude-dir=build --exclude-dir=coverage --exclude-dir=.next --exclude-dir=.cache \
      --exclude=scripts/antigravity_env_check.sh \
      "$FORBIDDEN_RE" "$REPO_ROOT" >/dev/null 2>&1; then
    echo "Matches:"
    grep -RInI -E --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.svelte-kit --exclude-dir=.vercel \
      --exclude-dir=dist --exclude-dir=build --exclude-dir=coverage --exclude-dir=.next --exclude-dir=.cache \
      --exclude=scripts/antigravity_env_check.sh \
      "$FORBIDDEN_RE" "$REPO_ROOT" | head -n 50
    fail "Found forbidden absolute host-path references in repo text files"
=======
  if command -v rg >/dev/null 2>&1; then
    if rg -n "$FORBIDDEN_RE" -- "${RUNTIME_FILES[@]}"; then
      fail "Found forbidden absolute host-path references in runtime source/config files"
    else
      pass "No forbidden absolute host-path references found"
    fi
>>>>>>> a359902 (fix(antigravity): make env check portable; scan runtime only)
  else
    if grep -nE "$FORBIDDEN_RE" -- "${RUNTIME_FILES[@]}" 2>/dev/null; then
      fail "Found forbidden absolute host-path references in runtime source/config files"
    else
      pass "No forbidden absolute host-path references found"
    fi
  fi
fi

echo
echo "Check: .env files present"
ENV_HITS="$(find "$REPO_ROOT" \
  -path "$REPO_ROOT/.git" -prune -o \
  -path "$REPO_ROOT/node_modules" -prune -o \
  -name ".env*" -type f -print 2>/dev/null || true)"
if [ -n "${ENV_HITS:-}" ]; then
  echo "$ENV_HITS" | head -n 50
  fail "Found .env* files (must not exist in repo)"
else
  pass "No .env* files found"
fi

<<<<<<< HEAD
echo
echo "Check: symlinks escaping workspace root"
# Scan ALL symlinks under repo (excluding junk), not just git-tracked ones.
SYMLINKS="$(find "$REPO_ROOT" \
  -path "$REPO_ROOT/.git" -prune -o \
  -path "$REPO_ROOT/node_modules" -prune -o \
  -path "$REPO_ROOT/.svelte-kit" -prune -o \
  -path "$REPO_ROOT/.vercel" -prune -o \
  -type l -print 2>/dev/null || true)"
=======
say
# ---------------------------
# Check 3: symlinks escaping workspace root (git-tracked symlinks only)
say "Check: symlinks escaping workspace root (git-tracked only)"
SYMS=()
while IFS= read -r p; do
  [ -n "$p" ] && SYMS+=("$p")
done < <(git ls-files -s | awk '$1 ~ /^120000/ {print $4}' || true)
>>>>>>> a359902 (fix(antigravity): make env check portable; scan runtime only)

if [ -z "${SYMLINKS:-}" ]; then
  pass "No symlinks found"
else
<<<<<<< HEAD
  ESCAPES=0
  while IFS= read -r L; do
    [ -z "$L" ] && continue
    TARGET="$(python3 - <<PY
=======
  ESCAPE=0
  for p in "${SYMS[@]}"; do
    RESOLVED="$(
      python3 - <<PY
>>>>>>> a359902 (fix(antigravity): make env check portable; scan runtime only)
import os, sys
p=sys.argv[1]
try:
<<<<<<< HEAD
  print(os.path.realpath(p))
=======
  print(os.path.realpath(path))
>>>>>>> a359902 (fix(antigravity): make env check portable; scan runtime only)
except Exception:
  print("")
PY
"$L")"
    if [ -z "${TARGET:-}" ]; then
      echo "Broken symlink: $L"
      ESCAPES=$((ESCAPES+1))
      continue
    fi
    case "$TARGET" in
      "$WORKSPACE_ROOT"/*) : ;;
      *)
        echo "Symlink escapes workspace:"
        echo "  link:   $L"
        echo "  target: $TARGET"
        ESCAPES=$((ESCAPES+1))
        ;;
    esac
  done <<< "$SYMLINKS"

  if [ "$ESCAPES" -gt 0 ]; then
    fail "One or more symlinks escape the workspace root"
  else
    pass "All symlinks remain within workspace root"
  fi
fi

<<<<<<< HEAD
echo
echo "Check: git status"
if git -C "$REPO_ROOT" diff --quiet && git -C "$REPO_ROOT" diff --cached --quiet; then
=======
say
# ---------------------------
# Check 4: git status (warn only)
say "Check: git status"
if git diff --quiet && git diff --cached --quiet; then
>>>>>>> a359902 (fix(antigravity): make env check portable; scan runtime only)
  pass "Working tree clean"
else
  warn "Working tree dirty (not a security failure, but be intentional)"
  git -C "$REPO_ROOT" status --porcelain | head -n 50 || true
fi

echo
echo "--------------------------------------------------------------------------------"
echo "Result:"
echo "  PASS=$PASS"
echo "  WARN=$WARN"
echo "  FAIL=$FAIL"
echo "--------------------------------------------------------------------------------"
echo

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
