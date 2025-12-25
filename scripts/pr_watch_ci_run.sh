#!/usr/bin/env bash
set -euo pipefail

PR="${1:-}"
REPO="${2:-}"
WF_PATH="${3:-.github/workflows/ci.yml}"

if [[ -z "$PR" || -z "$REPO" ]]; then
  echo "Usage: $0 <PR_NUMBER> <OWNER/REPO> [workflow_path]" >&2
  exit 2
fi

BRANCH="$(gh pr view "$PR" --repo "$REPO" --json headRefName --jq .headRefName)"
HEAD_SHA="$(gh pr view "$PR" --repo "$REPO" --json headRefOid --jq .headRefOid)"

WF_NAME="$(gh workflow list --repo "$REPO" --json name,path --jq ".[] | select(.path==\"$WF_PATH\") | .name")"
if [[ -z "$WF_NAME" ]]; then
  echo "ERROR: workflow not found at $WF_PATH in $REPO" >&2
  exit 1
fi

echo "=== Repo:   $REPO"
echo "=== PR:     #$PR"
echo "=== Branch: $BRANCH"
echo "=== Head:   $HEAD_SHA"
echo "=== WF:     $WF_NAME ($WF_PATH)"

find_run_id() {
  gh run list \
    --repo "$REPO" \
    --branch "$BRANCH" \
    --workflow "$WF_NAME" \
    --json databaseId,headSha,status,conclusion,createdAt,event \
    --jq "sort_by(.createdAt) | reverse | .[] | select(.headSha==\"$HEAD_SHA\") | .databaseId" \
  | head -n 1
}

RUN_ID="$(find_run_id || true)"

if [[ -z "${RUN_ID:-}" ]]; then
  echo "=== No run found for head SHA. Dispatching workflow (requires workflow_dispatch enabled)..."
  gh workflow run "$WF_NAME" --repo "$REPO" --ref "$BRANCH" >/dev/null

  # Wait/poll for run to appear
  for _ in $(seq 1 30); do
    RUN_ID="$(find_run_id || true)"
    [[ -n "${RUN_ID:-}" ]] && break
    sleep 2
  done
fi

if [[ -z "${RUN_ID:-}" ]]; then
  echo "ERROR: Could not find a workflow run for head SHA after dispatch." >&2
  echo "Fix: ensure ci.yml has: on: { pull_request: ..., workflow_dispatch: ... }" >&2
  exit 1
fi

echo "=== Watching run: $RUN_ID"
gh run watch "$RUN_ID" --repo "$REPO"

CONC="$(gh run view "$RUN_ID" --repo "$REPO" --json conclusion --jq .conclusion)"
if [[ "$CONC" != "success" ]]; then
  echo "ERROR: CI run conclusion=$CONC (run=$RUN_ID)" >&2
  exit 1
fi

echo "=== CI OK (run=$RUN_ID)"
