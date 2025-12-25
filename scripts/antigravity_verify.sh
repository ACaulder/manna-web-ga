#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$HERE/scripts/antigravity_env_check.sh"
npm run build

echo "Google Antigravity verification complete."
