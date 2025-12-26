# Google Antigravity — Security Boundaries (Repo Marker)

This repo is intended to run under the Google Antigravity secure workspace.

## Workspace Root

`~/ANTIGRAVITY_SANDBOX/`

## Non-negotiable Rules

- No references to:
  - `~/Library/Mobile Documents/`
  - `~/Library/CloudStorage/`
  - `~/MANNA/`
  - absolute `$HOME/...` paths outside the workspace root
- No `.env` files committed or present inside the repo (excluding dependency folders)
- No symlinks escaping the workspace root
- No destructive default operations

## Verification

Run:

- `scripts/antigravity_env_check.sh`
- `scripts/antigravity_verify.sh`

If either fails, the environment is not secure.

## Forbidden

**Hard rules (non-negotiable):**

- **No forbidden host paths in runtime code/config** (anything shipped or executed by CI/runtime), including:
  - `/Library/Mobile Documents/`
  - `/Library/CloudStorage/`
  - `$HOME/Library/Mobile Documents/`
  - `$HOME/Library/CloudStorage/`
- **No committed secrets** (`.env`, API keys, tokens, credentials).
- **No git-tracked symlinks that escape the workspace root** (prevents boundary bypass).
- **No implicit access** to host data outside the repo workspace (iCloud, Desktop/Documents, etc.).

**Enforcement:** `scripts/antigravity_env_check.sh` and CI (`scripts/antigravity_verify.sh`).

## Allowed commands

Commands that are safe and expected within the workspace boundary:

- `npm ci`, `npm run lint`, `npm run build`
- `bash ./scripts/antigravity_env_check.sh`
- `bash ./scripts/antigravity_verify.sh`
- `git status`, `git diff`, `git add`, `git commit`, `git push`
- `gh pr create`, `gh pr checks`, `gh pr merge`, `gh run list`, `gh run view`

Anything that reads/writes outside the repo workspace is **not allowed**.
