#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$HERE/scripts/antigravity_env_check.sh"

npm install
npm run lint
npm run build

echo "Google Antigravity setup complete."
