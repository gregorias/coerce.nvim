tests_init := "tests/busted.lua"

# Initialize the repository.
init:
  lefthook install
  # Initialize LuaRocks
  luarocks make *.rockspec
  # Install test dependencies.
  # Force using the package tree.
  luarocks test --prepare --tree=lua_modules
  # Fix https://github.com/lunarmodules/luacov/issues/122
  cp -r lua_modules/lib/luarocks/rocks-5.1/luacov/*/src lua_modules/share/lua/5.1/luacov/reporter
  direnv allow

generate-test-coverage-report:
  @luacov

test:
  @busted
