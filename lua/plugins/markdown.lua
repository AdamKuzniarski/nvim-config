return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "markdown.mdx" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			completions = {
				lsp = {
					enabled = true,
				},
			},
		},
		keys = {
			{
				"<leader>mr",
				"<cmd>RenderMarkdown toggle<CR>",
				ft = { "markdown", "markdown.mdx" },
				desc = "Toggle markdown render",
			},
		},
	},
}
