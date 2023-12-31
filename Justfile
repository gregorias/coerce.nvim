tests_init := "tests/minimal_init.lua"
tests_dir := "tests/"

test:
  @nvim \
    --headless \
    --noplugin \
    -u {{tests_init}} \
    -c "PlenaryBustedDirectory {{tests_dir}} { minimal_init = '{{tests_init}}' }"
