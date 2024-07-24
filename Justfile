tests_init := "tests/busted.lua"
tests_dir := "tests/"

test:
  @nvim \
    -l {{tests_init}} {{tests_dir}}
