#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: current directory is not a git repository" >&2
  exit 1
fi

# Hardcoded Git profile for notes_at_dragoncourt.
git config --local --unset-all include.path >/dev/null 2>&1 || true
git config --local user.name "Leviathan-A"
git config --local user.email "1151858182@qq.com"

echo "Applied local git profile:"
git config --local --show-origin user.name
git config --local --show-origin user.email

if [[ "${1:-}" == "--write-envrc" ]]; then
  cat > .envrc <<'EOF'
# Hardcoded Git profile for notes_at_dragoncourt.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config --local --unset-all include.path >/dev/null 2>&1 || true
  git config --local user.name "Leviathan-A" >/dev/null 2>&1
  git config --local user.email "1151858182@qq.com" >/dev/null 2>&1
fi
EOF
  echo "Wrote .envrc with hardcoded Leviathan profile."
fi
