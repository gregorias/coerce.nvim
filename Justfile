tests_init := "tests/busted.lua"
tests_dir := "tests/"

generate-test-coverage-report:
  @luacov

test:
  @nvim \
    -l {{tests_init}} {{tests_dir}}
