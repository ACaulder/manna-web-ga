#!/usr/bin/env bash
set -euo pipefail

ID="${1:-}"
MODE="${2:-prod-only}"

if [[ -z "$ID" ]]; then
  echo "Usage: $0 G-XXXXXXXXXX [prod-only|with-preview]" >&2
  exit 2
fi

./scripts/ga_set_vercel_env.sh "$ID" "$MODE"
./scripts/ga_wire_sveltekit.sh

npx prettier --write src/lib/Analytics.svelte src/routes/+layout.svelte
npm run lint
npm run build

echo "GA setup complete."
