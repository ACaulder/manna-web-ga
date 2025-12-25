# Google Antigravity — Security Boundaries (Repo Marker)

This repo is intended to run under the Google Antigravity secure workspace.

## Workspace Root

`~/ANTIGRAVITY_SANDBOX/`

## Non-negotiable Rules

- No references to:
  - `~/Library/Mobile Documents/`
  - `~/Library/CloudStorage/`
  - `~/MANNA/`
  - absolute `/Users/...` paths outside the workspace root
- No `.env` files committed or present inside the repo (excluding dependency folders)
- No symlinks escaping the workspace root
- No destructive default operations

## Verification

Run:

- `scripts/antigravity_env_check.sh`
- `scripts/antigravity_verify.sh`

If either fails, the environment is not secure.
