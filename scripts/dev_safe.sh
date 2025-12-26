#!/usr/bin/env bash
set -euo pipefail

SRC="${HOME}/MANNA/MannaWorker/var/summaries"
DEST="var/summaries"

mkdir -p "$DEST"
chmod -R u+w var 2>/dev/null || true
rsync -a --delete "${SRC}/" "${DEST}/"
chmod -R a-w "$DEST"

# hard fail if any host path leaks into runtime source
if rg -n -F "/Users/" src; then
  echo "FAIL: /Users/ found in src" >&2
  exit 1
fi

npm ci
bash ./scripts/antigravity_verify.sh
VITE_SUMMARY_DIR="var/summaries" npm run dev -- --host 127.0.0.1 --port 4173
