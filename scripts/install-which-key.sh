#!/usr/bin/env bash
# Installs Clone (Which Key) into deps/.
# Which Key is an optional dependency and having it in deps lets LuaLS provide
# accurate type information.

set -o errexit

mkdir -p deps
if [ ! -d deps/which-key.nvim ]; then \
  git clone --depth 1 https://github.com/folke/which-key.nvim deps/which-key.nvim
fi
