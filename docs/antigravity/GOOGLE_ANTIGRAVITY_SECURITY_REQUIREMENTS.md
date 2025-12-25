# Google Antigravity — Secure Runtime Requirements (Ticket-Ready)

## 0) Purpose

Establish a **secure, reproducible, auditable** environment to develop and run **Google Antigravity** on a single macOS user account, while preventing accidental access to unrelated personal data and preventing secrets leakage.

This document defines the work as a sequence of tickets with objective completion checks.

---

## 1) Non-Negotiable Security Invariants

These must remain true at all times.

1. **Workspace boundary:** Google Antigravity work happens under `~/ANTIGRAVITY_SANDBOX/` only.
2. **No hidden data reach-through:** No code, scripts, config, or tooling may read from:
   - `~/Library/Mobile Documents/`
   - `~/Library/CloudStorage/`
   - `~/MANNA/`
   - any other external path outside `~/ANTIGRAVITY_SANDBOX/`
3. **No secrets in git:** No tokens, keys, credentials, or private IDs in repository history, commit diffs, logs, or screenshots.
4. **No destructive automation:** No scripts that delete/move mass files outside `~/ANTIGRAVITY_SANDBOX/`.
5. **Reproducible setup:** A new machine can recreate the environment from scratch with documented commands and deterministic checks.

---

## 2) Directory Layout (Required)

- `~/ANTIGRAVITY_SANDBOX/`
  - `<project-repo>/` (the Google Antigravity codebase)
    - `docs/antigravity/` (this spec, plus runbooks)
    - `scripts/antigravity_*` (security/verification scripts)
    - `.env.example` (template only, never real secrets)

---

## 3) Required “Security Marker” Files (Repo-Level)

The repo MUST contain these files. They are used by automated checks to verify the environment is hardened:

1. `SECURITY_BOUNDARIES.md`
2. `scripts/antigravity_env_check.sh`
3. `scripts/antigravity_setup.sh`
4. `scripts/antigravity_verify.sh`

**Definition of Done:** a single command prints PASS for all checks:

- `./scripts/antigravity_verify.sh`

---

## 4) Secrets Handling Requirements

### 4.1 Allowed secret storage

- macOS Keychain OR
- a local file under `~/ANTIGRAVITY_SANDBOX/_secrets/` that is:
  - excluded by `.gitignore`
  - excluded by any packaging/build steps
  - never printed to stdout

### 4.2 Prohibited secret storage

- committed `.env`
- any file inside repo tracked by git
- shell history containing raw secrets (avoid `export SECRET=...` typed directly)

**Completion checks:**

- `git status` clean
- `rg -n "(API_KEY|SECRET|TOKEN|PASSWORD|PRIVATE)" .` returns only templates/docs, never real values

---

## 5) Data Access & Isolation Requirements

### 5.1 Boundary scanning

We need an automated scan that fails when code/config references forbidden paths.

Forbidden path patterns (minimum):

- `~/Library/Mobile Documents`
- `~/Library/CloudStorage`
- `/Users/<user>/Library/Mobile Documents`
- `/Users/<user>/Library/CloudStorage`
- `~/MANNA`
- `/Users/<user>/MANNA`

**Completion checks:**

- `./scripts/antigravity_env_check.sh` reports:
  - no escaping symlinks
  - no forbidden path hits
  - no `.env` files tracked
  - clean repo boundary

---

## 6) Build & Execution Requirements

1. **No network surprises:** any network access must be explicit and documented (what, why, where).
2. **Deterministic verification:** verification scripts must produce consistent output and exit codes:
   - exit `0` = pass
   - exit `1` = warnings (non-fatal)
   - exit `2` = fail
3. **Minimal dependencies:** prefer shell + node already in use; no heavy frameworks introduced just for verification.

**Completion checks:**

- `./scripts/antigravity_setup.sh` completes without interactive prompts (or clearly documents prompts)
- `./scripts/antigravity_verify.sh` passes locally on a fresh clone inside `~/ANTIGRAVITY_SANDBOX/`

---

## 7) Ticket Backlog (Sequential, With Acceptance Criteria)

### ANTIGRAVITY-001 — Establish security boundaries doc

**Goal:** Create `SECURITY_BOUNDARIES.md` that defines allowed roots, forbidden paths, and safe operational rules.

**Tasks:**

- Add `SECURITY_BOUNDARIES.md` with:
  - allowed root = `~/ANTIGRAVITY_SANDBOX/`
  - forbidden roots list (see §5)
  - “no secrets in git” rules
  - safe deletion guidance for sandboxed folders

**Acceptance Criteria:**

- File exists, is committed, and matches invariants in §1
- `rg -n "ANTIGRAVITY_SANDBOX" SECURITY_BOUNDARIES.md` shows correct allowed root

**Next:** ANTIGRAVITY-002

---

### ANTIGRAVITY-002 — Implement environment check script

**Goal:** Implement `scripts/antigravity_env_check.sh` as read-only guard rails.

**Tasks:**

- Script checks:
  - current working directory is inside `~/ANTIGRAVITY_SANDBOX/`
  - no tracked `.env`
  - no forbidden path references in repo (`rg` scan)
  - symlink escape detection (symlink target outside allowed root)
  - report + exit codes (0/1/2)

**Acceptance Criteria:**

- `./scripts/antigravity_env_check.sh` prints a clear PASS/FAIL summary
- Running it in the repo returns exit `0`

**Next:** ANTIGRAVITY-003

---

### ANTIGRAVITY-003 — Implement setup script (secure, repeatable)

**Goal:** `scripts/antigravity_setup.sh` prepares the environment safely.

**Tasks:**

- Ensure repo dependencies install in a bounded way
- Ensure `.gitignore` covers secrets folder(s)
- Ensure “setup” does not read forbidden paths

**Acceptance Criteria:**

- `./scripts/antigravity_setup.sh` succeeds on a fresh clone in `~/ANTIGRAVITY_SANDBOX/`
- Setup does not create tracked secret files
- Post-setup: `git status` clean

**Next:** ANTIGRAVITY-004

---

### ANTIGRAVITY-004 — Implement verification script (single command truth)

**Goal:** `scripts/antigravity_verify.sh` becomes the canonical “is it safe + working?” command.

**Tasks:**

- Runs env check
- Runs lint/build/tests (project-specific)
- Runs boundary scan
- Fails fast with actionable messages

**Acceptance Criteria:**

- `./scripts/antigravity_verify.sh` returns exit `0` when healthy
- Any failure produces a “what failed + how to fix” message

**Next:** ANTIGRAVITY-005

---

### ANTIGRAVITY-005 — Continuous integration enforcement

**Goal:** Prevent regressions.

**Tasks:**

- Add CI step that runs:
  - `scripts/antigravity_verify.sh`
- Block merges when verification fails

**Acceptance Criteria:**

- A pull request cannot be merged if verification fails
- CI logs clearly show which check failed

**Next:** ANTIGRAVITY-006

---

### ANTIGRAVITY-006 — Operational runbook

**Goal:** Make operations boring and safe.

**Tasks:**

- Add `docs/antigravity/RUNBOOK.md` with:
  - how to set secrets safely
  - how to run locally
  - how to verify
  - how to rotate secrets
  - how to decommission sandbox

**Acceptance Criteria:**

- A new operator can run Google Antigravity from scratch using only runbook commands

---

## 8) Definition of “Secure Enough to Run”

Google Antigravity is considered secure to run when ALL are true:

- `./scripts/antigravity_verify.sh` passes (exit 0)
- no forbidden path references exist in repo
- no secrets are tracked by git
- workspace is bounded to `~/ANTIGRAVITY_SANDBOX/`
- CI enforces verification
