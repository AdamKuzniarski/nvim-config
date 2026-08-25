# Neovim config

My personal, modular Neovim configuration for frontend, WordPress, PHP and Swift development.

## Stack

- Neovim 0.12+
- `lazy.nvim` for plugin management
- Native Neovim LSP configuration
- `nvim-cmp` and LuaSnip for completion
- Treesitter for syntax parsing
- Conform for formatting
- Telescope, nvim-tree and gitsigns for navigation and Git workflows

## Installation

```bash
git clone git@github.com:AdamKuzniarski/nvim-config.git ~/.config/nvim
nvim
```

On the first start, `lazy.nvim` installs the configured plugins automatically.

External language servers and formatters must be installed separately.
