# Initialize the repository:
#
# 1. Hook up Lefthook
# 2. Set up Luarocks and Lua test dependencies.
# 3. Enable Direnv.
init:
  lefthook install
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
  direnv allow

generate-test-coverage-report:
  @luacov

luacheck:
  @luacheck .

test:
  @busted

bump:
  ./scripts/bump

push-current-version:
  ./scripts/push-current-version
