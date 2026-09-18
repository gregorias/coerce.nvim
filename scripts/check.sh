#!/usr/bin/env bash
set -euo pipefail

workspace_root="$(jj workspace root 2>/dev/null || pwd)"
cd "$workspace_root"

# Use Lefthook with --colors=on to preserve ANSI coloring.
jj run --ignore-changes -r "(remote_bookmarks()..@-) ~ root()" -- lefthook run --colors=on check
jj run --ignore-changes -r "(remote_bookmarks()..@-) ~ root()" -- just lint-commit-msg
