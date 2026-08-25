return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo", "Format" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({
						async = true,
						lsp_format = "fallback",
					})
				end,
				mode = { "n", "v" },
				desc = "Format file",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				prisma = { "prisma_format" },

				swift = { "swift" },
				-- kein externer Formatter für php mehr -- läuft jetzt komplett
				-- über intelephense.format.enable = true (lsp.lua) + den
				-- lsp_format = "fallback" unten in den keys/config.

				javascript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },

				json = { "prettierd", "prettier", stop_after_first = true },
				jsonc = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				scss = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
			},

			format_on_save = function(bufnr)
				if vim.bo[bufnr].filetype == "php" then
					return nil
				end
				return {
					timeout_ms = 1000,
					lsp_format = "fallback",
				}
			end,
			formatters = {
				prisma_format = {
					command = "npx",
					args = { "prisma", "format", "--schema", "$FILENAME" },
					stdin = false,
					cwd = function(_, ctx)
						return vim.fs.root(ctx.filename, { "package.json", ".git" })
					end,
					require_cwd = true,
				},
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)

			vim.api.nvim_create_user_command("Format", function()
				require("conform").format({
					async = true,
					lsp_format = "fallback",
				})
			end, {})
		end,
	},
}
