#!/bin/sh
set -e
git config core.hooksPath .githooks
echo "✅ core.hooksPath set to .githooks"
