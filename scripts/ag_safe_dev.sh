#!/usr/bin/env bash
set -euo pipefail

SRC="$HOME/MANNA/MannaWorker/var/summaries"
DEST="var/summaries"

mkdir -p "$DEST"
chmod -R u+w "var" 2>/dev/null || true
rsync -a --delete "$SRC/" "$DEST/"
chmod -R a-w "$DEST"

perl -pi -e "s|const SUMMARY_DIR\\s*=\\s*'[^']*';|const SUMMARY_DIR = 'var/summaries';|g" src/routes/api/manna/+page.svelte

npm ci
bash ./scripts/antigravity_verify.sh
npm run dev -- --host 127.0.0.1 --port 4173
