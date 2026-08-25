vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"markdown",
		"text",
		"gitcommit",
	},
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us"
	end,
})

vim.api.nvim_create_user_command("JsonCheck", function()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("Save the JSON file before checking it", vim.log.levels.WARN)
		return
	end

	vim.system({ "jq", "empty", file }, { text = true }, function(result)
		vim.schedule(function()
			if result.code == 0 then
				vim.notify("JSON is valid", vim.log.levels.INFO)
			else
				vim.notify(vim.trim(result.stderr), vim.log.levels.ERROR)
			end
		end)
	end)
end, { desc = "Validate the current JSON file with jq" })

if vim.fn.exists(":LspInfo") == 0 then
	vim.api.nvim_create_user_command("LspInfo", function()
		vim.cmd("checkhealth vim.lsp")
	end, { desc = "Show Neovim LSP health information" })
end

-- WordPress-Block-Kommentare (<!-- wp:group {...} -->): Highlighting +
-- cmp-Source für Blocknamen. Über InsertEnter + vim.schedule geladen,
-- damit nvim-cmp/LuaSnip (lazy = InsertEnter in plugins/completion.lua)
-- garantiert schon initialisiert sind, wenn wpgutenberg.setup() cmp
-- anspricht.
vim.api.nvim_create_autocmd("InsertEnter", {
	once = true,
	callback = function()
		vim.schedule(function()
			require("util.wpgutenberg").setup()
		end)
	end,
})
