#!/usr/bin/env bash
# MCP stdio entry: do not rely on Cursor setting cwd to pine_mcp/ (often unset or wrong).
set -e
if [[ -s "${HOME}/.rvm/scripts/rvm" ]]; then
  # shellcheck source=/dev/null
  set +u
  source "${HOME}/.rvm/scripts/rvm"
fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT}"
exec bundle exec ruby bin/pine_mcp_server
