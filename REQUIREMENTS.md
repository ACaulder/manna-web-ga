# Google Antigravity — Secure Runtime Requirements

## What “Google Antigravity” refers to (explicit)

**Google Antigravity** is the isolated, security-hardened workspace and operational guardrails used to develop and run the Antigravity code without leaking or touching unrelated personal data outside the workspace root.

This document defines what “secure” means, how we verify it, and what tasks follow in a ticket system.

---

## Security Goal

Run and develop Google Antigravity safely on a single macOS user account **without**:

- reading or writing outside the Antigravity workspace root
- pulling in personal vaults or cloud-synced paths by accident
- storing secrets in the repo or on disk in plaintext
- allowing accidental destructive commands

---

## Workspace Root (single source of truth)

**Workspace Root:** `~/ANTIGRAVITY_SANDBOX/`

All Google Antigravity code, docs, temporary outputs, and scripts must live under this root.

---

## Security Boundaries (hard rules)

### Forbidden (must never occur)

- Any code path, config, or script referencing:
  - `~/Library/Mobile Documents/`
  - `~/Library/CloudStorage/`
  - `~/MANNA/`
  - any absolute `$HOME/...` path outside `~/ANTIGRAVITY_SANDBOX/`
- Any symlink inside the repo that resolves to a target outside `~/ANTIGRAVITY_SANDBOX/`
- Any committed secrets:
  - `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa`, tokens, private credentials
- Any automation that performs destructive operations by default:
  - `rm -rf`, bulk `mv`, mass delete/overwrite, or “cleanup” without explicit user intent

### Allowed

- Standard development commands:
  - `npm install`
  - `npm run dev`
  - `npm run build`
  - `npm run preview`
  - `npm run lint`
  - `rg` / `grep` / `find`
  - `node` (one-off scripts)
- Read-only safety scans and validation scripts

---

## Secrets Handling (secure by design)

- Secrets must be injected at runtime via a secure mechanism (never committed).
- No `.env` files in the repo.
- If secrets must exist locally, they must be stored **outside the repo** and referenced via environment variables (and never logged).

---

## Verification Standard (Definition of “secure and complete”)

A setup is considered **secure** when all items below pass:

1. **Workspace boundary verification passes**
   - No forbidden path references
   - No escaping symlinks
   - No committed secrets
   - No accidental cross-root configuration

2. **Reproducible environment check exists**
   - A script exists that can be run repeatedly and returns non-zero on violations

3. **Operator runbook exists**
   - A short document explaining how to run the checks and what to do on failures

---

## Ticket-ready Task List

### Ticket 1 — Establish Google Antigravity Security Boundary Doc

**Dependency:** None  
**Deliverables:**

- `SECURITY_BOUNDARIES.md` at repo root describing:
  - workspace root
  - forbidden paths
  - secrets rules
  - allowed commands
    **Acceptance Criteria:**
- Document exists at repo root
- Document explicitly states “Google Antigravity” and the workspace root
- Document contains a “Forbidden” list and an “Allowed commands” list

---

### Ticket 2 — Add Google Antigravity Environment Check Script

**Dependency:** Ticket 1  
**Deliverables:**

- `scripts/antigravity_env_check.sh`
  **Acceptance Criteria:**
- Script is executable
- Script fails (exit 1+) if:
  - forbidden paths are referenced anywhere in repo text files
  - `.env*` files exist (excluding node_modules)
  - symlinks escape the workspace root
- Script prints a clear summary with PASS/FAIL markers

---

### Ticket 3 — Add Google Antigravity Setup Script (safe, idempotent)

**Dependency:** Ticket 2  
**Deliverables:**

- `scripts/antigravity_setup.sh`
  **Acceptance Criteria:**
- Script is executable
- Script performs only safe operations:
  - installs dependencies
  - runs lint/build
- Script does not write outside the workspace root
- Script does not create or require a new macOS user

---

### Ticket 4 — Add Google Antigravity Verification Script (runtime smoke test)

**Dependency:** Ticket 2  
**Deliverables:**

- `scripts/antigravity_verify.sh`
  **Acceptance Criteria:**
- Script is executable
- Script runs:
  - `scripts/antigravity_env_check.sh`
  - a minimal local build/preview smoke test (or equivalent)
- Script exits non-zero on any failure

---

### Ticket 5 — Integrate Verification Into CI (optional but recommended)

**Dependency:** Ticket 4  
**Deliverables:**

- CI job step calling `scripts/antigravity_verify.sh`
  **Acceptance Criteria:**
- CI fails when boundary rules are broken
- CI passes when verification passes

---

## What task follows what

- Ticket 1 → Ticket 2 → Ticket 3 + Ticket 4 → Ticket 5
