#!/bin/bash
set -euo pipefail

# Only run in Claude Code cloud sessions
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}"

# pip installs into the system Python, so keep the hash file in its package directory
pyhashes="$(python3 -I -c 'import sysconfig; print(sysconfig.get_path("purelib"))')/.session-start.sha256"
if ! sha256sum --check --status "$pyhashes" 2>/dev/null; then
  rm -f "$pyhashes"
  python3 -m pip install -q -r requirements.txt -r requirements-tests.txt
  python3 -m pip install -q --use-pep517 -e .
  sha256sum "$PWD/.claude/hooks/session-start.sh" "$PWD/requirements.txt" \
    "$PWD/requirements-tests.txt" "$PWD/setup.py" > "$pyhashes" || rm -f "$pyhashes"
fi

echo 'export PYTHONPATH="'"$PWD"'${PYTHONPATH:+:$PYTHONPATH}"' >> "${CLAUDE_ENV_FILE:-/dev/null}"
