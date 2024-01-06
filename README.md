<!-- markdownlint-disable MD033 MD041 -->

<div align="center">
  <p>
    <img src="assets/coerce-fist-name.png" align="center" alt="Coerce Logo"
         width="400" />
  </p>
  <p>
    A Neovim plugin for changing keyword case.
  </p>
</div>

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
| [Numeronym] “case”     | ✅          | ❌             | ❌      |

## Acknowledgments

This plugin is based on [Abolish][abolish]'s coercion feature. I created this
plugin precisely to address its shortcomings, which are:

- lack of configurability
- no integration with [Which Key][which-key]

[abolish]: https://github.com/tpope/vim-abolish
[which-key]: https://github.com/folke/which-key.nvim
[Numeronym]: https://en.wikipedia.org/wiki/Numeronym#Numerical_contractions
