<!-- markdownlint-disable MD013 MD033 MD041 -->

<div align="center">
  <p>
    <img src="assets/coerce-fist-name.png" align="center" alt="Coerce Logo"
         width="400" />
  </p>
  <p>
    A Neovim plugin for changing keyword case.
  </p>
</div>

## Example session

![tty](assets/coerce-session.gif)

## ⚡️ Requirements

- Neovim 0.9+
- Optional plugin dependencies:
  - [Which Key][which-key]
  - [Legendary]

## 📦 Installation

Install the theme with your preferred package manager, such as [Lazy]:

```lua
{
  "gregorias/coerce.nvim",
  config = true,
}
```

## 🚀 Usage

1. Put the cursor inside [a keyword][iskeyword].
2. Press `crX`, where `X` stands for your desired case. Which key, if present,
   will show you hints.

### Built-in cases

| Case       | Key |
| :--        | :-- |
| camelCase  | c   |
| dot.case   | d   |
| kebab-case | k   |
| n12e       | n   |
| PascalCase | p   |
| snake_case | s   |
| UPPER_CASE | u   |

## ⚙️ Configuration

## Comparison to similar tools

| Feature                 | Coerce | [Text-case][text-case] | [Abolish][abolish] |
| :--                     | :--:   | :--:                   | :--:               |
| Unicode support         | ✅     |                        | ❌                 |
| Which Key integration   | ✅     | ✅                     | ❌                 |
| [Telescope] integration |        | ✅                     | ❌                 |
| [Legendary] integration |        |                        | ❌                 |
| LSP rename              | ❌     | ✅                     | ❌                 |
| Operator motion support | ❌     | ✅                     | ❌                 |
| Current keyword coerce  | ✅     | ❌                     | ✅                 |
| Kebab case              | ✅     | ❌                     | ✅                 |
| [Numeronym] “case”      | ✅     | ❌                     | ❌                 |
| Custom case support     | ✅     | ❌                     | ❌                 |

## Acknowledgments

This plugin was inspired by [Abolish][abolish]’s coercion feature. I created
this plugin to address Abolish’s shortcomings, which are:

- No integration with [Which Key][which-key] or [Legendary].
- Little configurability. I couldn’t extend the plugin with new cases.

I used [Text-case][text-case]’s source code to inform myself on how to do
things in Neovim.

The logo is based on
[a fist SVG from SVG Repo](https://www.svgrepo.com/svg/29542/fist).

[abolish]: https://github.com/tpope/vim-abolish
[iskeyword]: https://neovim.io/doc/user/options.html#'iskeyword'
[text-case]: https://github.com/johmsalas/text-case.nvim
[which-key]: https://github.com/folke/which-key.nvim
[Legendary]: https://github.com/mrjones2014/legendary.nvim
[Lazy]: https://github.com/folke/lazy.nvim
[Numeronym]: https://en.wikipedia.org/wiki/Numeronym#Numerical_contractions
[Telescope]: https://github.com/nvim-telescope/telescope.nvim
