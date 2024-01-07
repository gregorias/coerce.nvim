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

## 📦 Installation

Install the plugin with your preferred package manager, such as [Lazy]:

```lua
{
  "gregorias/coerce.nvim",
  tag = 'v0.1.1',
  config = true,
}
```

### Abolish setup

This plugin effectively replaces [Abolish]’s coercion functionality. If you
wish to keep it for its other features, you can disable the coercion feature
like so:

```lua
{
  "tpope/vim-abolish",
  init = function()
    -- Disable coercion mappings. I use coerce.nvim for that.
    vim.g.abolish_no_mappings = true
  end,
}
```

### Note on stability

Coerce is under active development, and I intend to make breaking changes as I
explore the design space. For your peace of mind, consider freezing your
installation at a specific version for now. Fine by me if you want to live on
the bleeding edge though.

## 🚀 Usage

1. Put the cursor inside [a keyword][iskeyword].
2. Press `crX`, where `X` stands for your desired case. Which key, if present,
   will show you hints.

### Built-in cases

| Case              | Key |
| :--               | :-- |
| camelCase         | c   |
| dot.case          | d   |
| kebab-case        | k   |
| [n12e][Numeronym] | n   |
| PascalCase        | p   |
| snake_case        | s   |
| UPPER_CASE        | u   |
| path/case         | /   |

## ⚙️ Configuration

### Setup

The default configuration looks like so:

```lua
require"coerce".setup{
  coerce_prefix = "cr",
  keymap_registry = require("coerce.keymap").keymap_registry(),
}
```

You may freely modify the config parameters to your liking.

### Register a new case

You can register a new case like so:

```lua
require"coerce".register{
  keymap = "l",
  case = function(str)
    return vim.fn.tolower(str)
  end,
  description = "lowercase",
}
```

## Comparison to similar tools

[Text-case][text-case] is significantly more feature-rich than Coerce, but if
you just need to change case of the current keyword, Coerce is simpler.

| Feature                            | Coerce | [Text-case][text-case] | [Abolish][abolish] |
| :--                                | :--:   | :--:                   | :--:               |
| Full Unicode support               | ✅     | ❌                     | ❌                 |
| [Which Key][which-key] integration | ✅     | ✅                     | ❌                 |
| [Telescope] integration            | ❌     | ✅                     | ❌                 |
| LSP rename                         | ❌     | ✅                     | ❌                 |
| Operator motion support            | ❌     | ✅                     | ❌                 |
| Current keyword coerce             | ✅     | ❌                     | ✅                 |
| Kebab case                         | ✅     | ✅                     | ✅                 |
| [Numeronym] “case”                 | ✅     | ❌                     | ❌                 |
| Custom case support                | ✅     | ❌                     | ❌                 |

## 🙏 Acknowledgments

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
