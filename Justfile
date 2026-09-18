# List available recipes
default:
  @just --list

# Run all checks
check:
  @lefthook run check

# Run all formatters
format:
  @lefthook run format

# Initialize the repository:
# 1. Set up Jujutsu colocated repository and aliases.
# 2. Set up Luarocks and Lua test dependencies.
# 3. Enable Direnv.
init:
  if [ ! -d .jj ]; then \
    jj git init; \
  fi
  jj config set --repo 'revset-aliases."trunk()"' '"main@origin"'
  jj config set --repo 'aliases.check' '["util", "exec", "--", "sh", "-c", "\"$JJ_WORKSPACE_ROOT/scripts/check.sh\" \"$@\"", "check"]'
  jj config set --repo 'aliases.ship' '["util", "exec", "--", "sh", "-c", "\"$JJ_WORKSPACE_ROOT/scripts/ship.sh\" \"$@\"", "ship"]'
  luarocks init --lua-version 5.1 --lua-versions 5.1
  # Revert unnecessary changes.
  git restore .gitignore
  rm -f ./luarocks
  # Initialize LuaRocks
  luarocks build --only-deps --lua-version 5.1
  # Install test dependencies.
  # I couldn't figure out how to properly install them through Luarocks.
  # Even `luarocks test --prepare` doesn't install transitive deps.
  luarocks install busted
  luarocks install luacov
  luarocks install luacheck
  # Fix https://github.com/lunarmodules/luacov/issues/122
  cp -r lua_modules/lib/luarocks/rocks-5.1/luacov/*/src lua_modules/share/lua/5.1/luacov/reporter
  ./scripts/install-which-key.sh
  direnv allow

clean-test:
  rm -fr .tests/xdg/local
  rm -f  .tests/xdg/config/nvim/nvim-pack-lock.json

generate-test-coverage-report:
  @luacov

# Check Lua formatting
check-lua:
  stylua --check lua

# Format Lua files
format-lua:
  stylua lua

# Lint Lua files
lint-lua:
  @luacheck .

# Lint Markdown files
lint-markdown:
  fd -e md -X markdownlint

# Check Markdown links
check-links:
  lychee --accept "100..=103,200..=299,403,429" --root-dir=. DEV.md README.md IDEAS.md

# Check YAML formatting
check-yaml:
  fd -H -e yml -e yaml -X prettier -c

# Format YAML files
format-yaml:
  fd -H -e yml -e yaml -X prettier -w

# Run static type checking
typecheck:
  @bash scripts/typecheck.sh

# Run tests
test:
  @rm -f luacov.stats.out
  @busted

# Lint commit message using Jujutsu revision description
lint-commit-msg:
  jj log --no-graph -r "${JJ_COMMIT_ID:-@}" -T description | commitlint

alias lint-commit := lint-commit-msg

bump:
  ./scripts/bump

push-current-version:
  ./scripts/push-current-version
