local map = vim.keymap.set

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Basic file actions
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Commenting (Neovim's built-in gcc/gc mappings)
map("n", "<leader>cc", "gcc", { remap = true, desc = "Toggle comment line" })
map("x", "<leader>cc", "gc", { remap = true, desc = "Toggle selected comments" })

-- Diagnostics
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })

map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

-- Window navigation
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move to right window" })

-- Spellcheck
map("n", "<leader>ss", function()
	vim.opt_local.spell = not vim.opt_local.spell:get()

	if vim.opt_local.spell:get() then
		vim.opt_local.spelllang = "en_us"
		vim.notify("Spellcheck enabled: en_us", vim.log.levels.INFO)
	else
		vim.notify("Spellcheck disabled", vim.log.levels.INFO)
	end
end, { desc = "Toggle spellcheck" })

map("n", "<leader>sz", "z=", { desc = "Spell suggestions" })
map("n", "<leader>sg", "zg", { desc = "Add word to dictionary" })
map("n", "<leader>sw", "zw", { desc = "Mark word as wrong" })

map("n", "]s", "]s", { desc = "Next spelling error" })
map("n", "[s", "[s", { desc = "Previous spelling error" })

-- Terminal
map("n", "<leader>tt", "<cmd>botright 15split | terminal<CR>", { desc = "Open terminal below" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })
