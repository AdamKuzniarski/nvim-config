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

## 3D snippets

Type a trigger in Insert mode, select it with `<C-n>` and `<Enter>`, then move between editable fields with `<Tab>` and `<S-Tab>`. Use `<C-Space>` if the completion menu is hidden.

| Trigger | Where | Result |
| --- | --- | --- |
| `threestart` | Empty JavaScript/TypeScript file | Browser entry file with a rotating box, render loop, and resize handling |
| `threemesh` | JavaScript/TypeScript, including JSX/TSX | Mesh with editable geometry and material |
| `threeloop` | JavaScript/TypeScript, including JSX/TSX | Render loop for an existing scene |
| `threeorbit` | JavaScript/TypeScript, including JSX/TSX | Orbit controls for an existing camera and renderer |
| `threeresize` | JavaScript/TypeScript, including JSX/TSX | Resize handler for an existing renderer and perspective camera |
| `r3fmesh` | JSX/TSX | React Three Fiber mesh |

`threestart` already includes a render loop and resize handling, so it does not need `threeloop` or `threeresize`. It requires the `three` package and a browser entry point. For `threeorbit`, add `import { OrbitControls } from "three/addons/controls/OrbitControls.js";` yourself.
