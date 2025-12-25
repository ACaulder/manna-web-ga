#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ID="${1:-}"
if [[ -z "$ID" ]]; then
  echo "Usage: $0 G-XXXXXXXXXX" >&2
  exit 2
fi
if [[ "$ID" != G-* ]]; then
  echo "ERROR: Measurement ID should look like G-XXXXXXXXXX (got: $ID)" >&2
  exit 2
fi

command -v vercel >/dev/null 2>&1 || {
  echo "ERROR: vercel CLI not found. Install: npm i -g vercel" >&2
  exit 1
}

# Link THIS repo (creates ./\.vercel here, not in ~)
vercel link >/dev/null

echo "Setting PUBLIC_GA_MEASUREMENT_ID in Vercel (preview + production)..."
for ENV in preview production; do
  printf "%s" "$ID" | vercel env add PUBLIC_GA_MEASUREMENT_ID "$ENV" --force >/dev/null
  echo "  - $ENV: set"
done

echo "Done. Next deploy will include the env var."
