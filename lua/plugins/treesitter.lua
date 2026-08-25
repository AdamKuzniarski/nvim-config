return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false,
	config = function()
		require("nvim-treesitter").install({
			"lua",
			"vim",
			"vimdoc",
			"query",

			"javascript",
			"typescript",
			"tsx",

			"swift",

			"json",
			"html",
			"css",
			"scss",
			"php",
			"yaml",
			"bash",

			"markdown",
			"markdown_inline",
			"prisma",
		})

		local ts_filetypes = {
			"lua",
			"vim",
			"vimdoc",
			"query",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"swift",
			"json",
			"jsonc",
			"html",
			"css",
			"scss",
			"php",
			"yaml",
			"bash",
			"markdown",
			"prisma",
		}

		vim.api.nvim_create_autocmd("FileType", {
			pattern = ts_filetypes,
			callback = function()
				pcall(vim.treesitter.start)
			end,
		})

		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.opt.foldenable = false
	end,
}
