#!/usr/bin/env bash
set -euo pipefail

ID="${1:-}"
MODE="${2:-prod-only}"   # prod-only | with-preview

if [[ -z "$ID" ]]; then
  echo "Usage: $0 G-XXXXXXXXXX [prod-only|with-preview]" >&2
  exit 2
fi

if [[ "$ID" != G-* ]]; then
  echo "ERROR: Measurement ID must start with 'G-'. Got: $ID" >&2
  exit 2
fi

command -v vercel >/dev/null 2>&1 || {
  echo "ERROR: vercel CLI not found. Install: npm i -g vercel" >&2
  exit 1
}

# Ensure we are linked in THIS repo
vercel link >/dev/null

echo "Ensuring GA env var is PROD-only by default..."
# Remove from preview to prevent GA firing on preview deployments
vercel env rm PUBLIC_GA_MEASUREMENT_ID preview >/dev/null 2>&1 || true
echo "  - preview: removed (or already absent)"

# Set/overwrite production
printf "%s" "$ID" | vercel env add PUBLIC_GA_MEASUREMENT_ID production --force >/dev/null
echo "  - production: set"

if [[ "$MODE" == "with-preview" ]]; then
  printf "%s" "$ID" | vercel env add PUBLIC_GA_MEASUREMENT_ID preview --force >/dev/null
  echo "  - preview: set (requested)"
fi

echo "Done."
