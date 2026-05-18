#!/usr/bin/env bash
INPUT_CHECKLEVEL=Warning INPUT_CONFIGPATH=.luarc.json GITHUB_WORKSPACE="$PWD" lua scripts/typecheck.lua
