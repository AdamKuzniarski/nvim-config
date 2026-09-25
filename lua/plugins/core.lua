return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
      },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
        end

        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, "Next git hunk")

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, "Previous git hunk")

        map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
        map("n", "<leader>gs", gitsigns.stage_hunk, "Stage hunk")
        map("v", "<leader>gs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage hunk")
        map("n", "<leader>gr", gitsigns.reset_hunk, "Reset hunk")
        map("n", "<leader>gb", gitsigns.blame_line, "Blame line")
        map("n", "<leader>gd", gitsigns.diffthis, "Diff against index")
      end,
    },
  },

  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        filetypes = {
          "css",
          "scss",
          "html",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
        options = {
          parsers = {
            css = true,
            css_fn = true,
            hex = {
              rgb = true,
              rrggbb = true,
              rrggbbaa = true,
            },
          },
          display = { mode = "background" },
        },
      })
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
}
