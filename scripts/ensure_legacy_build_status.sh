#!/usr/bin/env bash
set -euo pipefail

WF="${1:-.github/workflows/ci.yml}"

python3 - <<'PY'
from pathlib import Path
import re, sys

wf = Path(sys.argv[1])
s = wf.read_text()
orig = s

# permissions: statuses: write
if re.search(r"(?m)^permissions:\s*$", s) is None:
    s = s.replace("\njobs:", "\npermissions:\n  contents: read\n  statuses: write\n\njobs:")
else:
    m = re.search(r"(?ms)^permissions:\n((?:[ \t].*\n)+)", s)
    if m:
        block = "permissions:\n" + m.group(1)
        if re.search(r"(?m)^[ \t]*statuses:\s*write\s*$", block) is None:
            if re.search(r"(?m)^[ \t]*statuses:\s*\w+\s*$", block):
                block2 = re.sub(r"(?m)^[ \t]*statuses:\s*\w+\s*$", "  statuses: write", block)
            else:
                block2 = block.rstrip("\n") + "\n  statuses: write\n"
            s = s[:m.start()] + block2 + s[m.end():]

# Already present?
if "context=build" in s or '"context":"build"' in s:
    wf.write_text(s)
    raise SystemExit(0)

# Insert step after the run-block containing PM="${PM:-npm}"
lines = s.splitlines(True)
pm_idx = next((i for i,l in enumerate(lines) if 'PM="${PM:-npm}"' in l), None)
if pm_idx is None:
    raise SystemExit("Couldn't find PM line to anchor insertion.")

run_idx = next((i for i in range(pm_idx, -1, -1) if re.match(r"^\s*run:\s*\|\s*$", lines[i])), None)
if run_idx is None:
    raise SystemExit("Couldn't find run: | block to anchor insertion.")

run_indent = len(re.match(r"^(\s*)", lines[run_idx]).group(1))
end_idx = len(lines)
for j in range(run_idx + 1, len(lines)):
    if lines[j].strip() == "":
        continue
    if len(re.match(r"^(\s*)", lines[j]).group(1)) <= run_indent:
        end_idx = j
        break

item_indent_len = max(0, run_indent - 2)
item_indent = " " * item_indent_len
key_indent = item_indent + "  "

step = [
    f"{item_indent}- name: Publish legacy required status (build)\n",
    f"{key_indent}if: ${{{{ success() }}}}\n",
    f"{key_indent}env:\n",
    f"{key_indent}  GH_TOKEN: ${{{{ github.token }}}}\n",
    f"{key_indent}run: |\n",
    f"{key_indent}  gh api -X POST \"repos/${{GITHUB_REPOSITORY}}/statuses/${{GITHUB_SHA}}\" \\\n",
    f"{key_indent}    -f state=success -f context=build \\\n",
    f"{key_indent}    -f description=\"CI passed\" \\\n",
    f"{key_indent}    -f target_url=\"${{GITHUB_SERVER_URL}}/${{GITHUB_REPOSITORY}}/actions/runs/${{GITHUB_RUN_ID}}\"\n",
]

lines = lines[:end_idx] + ["\n"] + step + lines[end_idx:]
wf.write_text("".join(lines))
PY "$WF"

touch .prettierignore
grep -qxF '.vercel/output' .prettierignore || echo '.vercel/output' >> .prettierignore
