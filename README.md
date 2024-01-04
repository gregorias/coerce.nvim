# 🔄 Coerce.nvim

A Neovim plugin for changing case of words.

## Comparison to similar tools

| Feature                | Coerce.nvim | Text-case.nvim | Abolish |
| :--:                   | :--:        | :--:           | :--:    |
| Unicode support        | ✅          |                | ❌      |
| Which Key support      | ✅          | ✅             | ❌      |
| Which Key integration  |             | ✅             | ❌      |
| Telescope integration  |             | ✅             | ❌      |
| LSP rename support     | ❌          | ✅             | ❌      |
| Current keyword coerce | ✅          | ❌             | ✅      |
| Kebab case             |             | ❌             | ✅      |
| Numeronym “case”       | ✅          | ❌             | ❌      |

## Acknowledgments

This plugin is based on [Abolish][abolish]'s coercion feature. I created this
plugin precisely to address its shortcomings, which are:

- lack of configurability
- no integration with [Which Key][which-key]

[abolish]: https://github.com/tpope/vim-abolish
[which-key]: https://github.com/folke/which-key.nvim
