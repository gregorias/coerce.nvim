# 🛠️ Developer documentation

This is a documentation file for developers.

## Dev environment setup

This project requires the following tools:

- [Commitlint]
- [Just]
- [Lefthook]
- [Stylua]

Install lefthook:

```shell
lefthook install
```

Install LuaRocks environment:

```shell
luarocks make
```

## Ops

To generate and open a test coverage report:

```shell
rm luacov.stats.out && just test && just generate-test-coverage-report && open luacov-html/index.html
```

## ARDs

### Using LuaRocks

I set up this plugin as a Lua package using LuaRocks.
Neovim plugins are effectively Lua packages that just use Neovim as the
intepreter.
Using LuaRocks lets me easily install and use Busted or LuaCov for tests.

[Commitlint]: https://github.com/conventional-changelog/commitlint
[Lefthook]: https://github.com/evilmartians/lefthook
[Just]: https://just.systems/
[Stylua]: https://github.com/JohnnyMorganz/StyLua
