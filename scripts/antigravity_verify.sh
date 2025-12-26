#!/usr/bin/env bash
echo "Antigravity verify: start"
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "$HERE/scripts/antigravity_env_check.sh"
npm run build

echo "ANTIGRAVITY_VERIFY_MARKER: antigravity_verify.sh"
echo "Google Antigravity verification complete."
