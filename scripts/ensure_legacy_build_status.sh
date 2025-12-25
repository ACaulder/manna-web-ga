#!/usr/bin/env bash
set -euo pipefail

WF="${1:-.github/workflows/ci.yml}"
[ -f "$WF" ] || { echo "ERROR: workflow not found: $WF"; exit 1; }

python3 - "$WF" <<'PY'
from pathlib import Path
import re, sys

wf = Path(sys.argv[1])
s = wf.read_text()

# --- permissions: add checks+statuses write ---
if re.search(r"(?m)^permissions:\s*$", s) is None:
    s = s.replace(
        "\njobs:",
        "\npermissions:\n  contents: read\n  checks: write\n  statuses: write\n\njobs:",
    )
else:
    m = re.search(r"(?ms)^permissions:\n((?:[ \t].*\n)+)", s)
    if m:
        block = "permissions:\n" + m.group(1)
        # ensure checks: write
        if re.search(r"(?m)^[ \t]*checks:\s*write\s*$", block) is None:
            if re.search(r"(?m)^[ \t]*checks:\s*\w+\s*$", block):
                block = re.sub(r"(?m)^[ \t]*checks:\s*\w+\s*$", "  checks: write", block)
            else:
                block = block.rstrip("\n") + "\n  checks: write\n"
        # ensure statuses: write
        if re.search(r"(?m)^[ \t]*statuses:\s*write\s*$", block) is None:
            if re.search(r"(?m)^[ \t]*statuses:\s*\w+\s*$", block):
                block = re.sub(r"(?m)^[ \t]*statuses:\s*\w+\s*$", "  statuses: write", block)
            else:
                block = block.rstrip("\n") + "\n  statuses: write\n"
        s = s[: m.start()] + block + s[m.end() :]

# Already added?
if "Publish required build gate (build)" in s:
    wf.write_text(s)
    print("ci.yml already patched for required build gate.")
    raise SystemExit(0)

lines = s.splitlines(True)

# Anchor: the big run block in your CI job contains PM="${PM:-npm}"
pm_idx = next((i for i, l in enumerate(lines) if 'PM="${PM:-npm}"' in l), None)
if pm_idx is None:
    raise SystemExit("ERROR: couldn't find anchor PM=\"${PM:-npm}\" in ci.yml")

run_idx = None
for i in range(pm_idx, -1, -1):
    if re.match(r"^\s*run:\s*\|\s*$", lines[i]):
        run_idx = i
        break
if run_idx is None:
    raise SystemExit("ERROR: couldn't locate run: | block above PM anchor")

run_indent = len(re.match(r"^(\s*)", lines[run_idx]).group(1))

# Find end of that run block
end_idx = len(lines)
for j in range(run_idx + 1, len(lines)):
    if lines[j].strip() == "":
        continue
    if len(re.match(r"^(\s*)", lines[j]).group(1)) <= run_indent:
        end_idx = j
        break

# Step indentation: list item is typically 2 spaces less than "run:"
item_indent = " " * max(0, run_indent - 2)
key_indent = item_indent + "  "

step = [
    "\n",
    f"{item_indent}- name: Publish required build gate (build)\n",
    f"{key_indent}if: ${{{{ success() }}}}\n",
    f"{key_indent}env:\n",
    f"{key_indent}  GH_TOKEN: ${{{{ github.token }}}}\n",
    f"{key_indent}  HEAD_SHA: ${{{{ github.event.pull_request.head.sha || github.sha }}}}\n",
    f"{key_indent}run: |\n",
    f"{key_indent}  echo \"Publishing required gate on $HEAD_SHA\"\n",
    f"{key_indent}  # 1) legacy commit status context (sometimes required)\n",
    f"{key_indent}  gh api -X POST \"repos/${{GITHUB_REPOSITORY}}/statuses/$HEAD_SHA\" \\\n",
    f"{key_indent}    -f state=success -f context=build \\\n",
    f"{key_indent}    -f description=\"CI passed\" \\\n",
    f"{key_indent}    -f target_url=\"${{GITHUB_SERVER_URL}}/${{GITHUB_REPOSITORY}}/actions/runs/${{GITHUB_RUN_ID}}\"\n",
    f"{key_indent}  # 2) check-run named exactly 'build' (this is the usual ruleset gate)\n",
    f"{key_indent}  gh api -X POST \"repos/${{GITHUB_REPOSITORY}}/check-runs\" \\\n",
    f"{key_indent}    -H \"Accept: application/vnd.github+json\" \\\n",
    f"{key_indent}    -f name=build \\\n",
    f"{key_indent}    -f head_sha=\"$HEAD_SHA\" \\\n",
    f"{key_indent}    -f status=completed \\\n",
    f"{key_indent}    -f conclusion=success \\\n",
    f"{key_indent}    -f 'output[title]=build' \\\n",
    f"{key_indent}    -f 'output[summary]=Published by CI to satisfy repo ruleset'\n",
]

lines = lines[:end_idx] + step + lines[end_idx:]
wf.write_text("".join(lines))
print("Patched ci.yml: added checks/statuses permissions + publishes required build check-run.")
PY

# Keep prettier away from Vercel artifacts forever
touch .prettierignore
grep -qxF '.vercel/output' .prettierignore || echo '.vercel/output' >> .prettierignore

echo "OK: ensure_legacy_build_status.sh finished"
