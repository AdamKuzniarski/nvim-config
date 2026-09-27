local M = {}
local live_updates_enabled = false

local function in_jsx_at_cursor(bufnr, row, col)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok then
		return nil
	end

	if not pcall(parser.parse, parser) then
		return nil
	end

	local node_ok, node = pcall(vim.treesitter.get_node, {
		bufnr = bufnr,
		pos = { row - 1, col },
	})
	if not node_ok then
		return nil
	end

	while node do
		if node:type():match("^jsx_") then
			return true
		end
		node = node:parent()
	end

	return false
end

function M.insert()
	local bufnr = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local in_jsx = in_jsx_at_cursor(bufnr, row, col)

	if in_jsx then
		vim.notify("Cannot insert console.log inside JSX markup", vim.log.levels.WARN)
		return
	end
	if in_jsx == nil and vim.bo[bufnr].filetype:match("react$") then
		vim.notify("Cannot insert console.log: JSX parser unavailable", vim.log.levels.WARN)
		return
	end

	require("lazy").load({ plugins = { "LuaSnip" } })
	local ls = require("luasnip")
	if not live_updates_enabled then
		ls.setup({ update_events = { "TextChanged", "TextChangedI" } })
		live_updates_enabled = true
	end

	local indent = line:match("^[ \t]*")
	vim.api.nvim_buf_set_lines(bufnr, row, row, false, { indent })
	ls.snip_expand(
		ls.snippet("", {
			ls.text_node('console.log("'),
			ls.function_node(function(args)
				return args[1][1]
			end, { 1 }),
			ls.text_node('", '),
			ls.insert_node(1),
			ls.text_node(");"),
		}),
		{ pos = { row, #indent } }
	)

	local winid = vim.api.nvim_get_current_win()
	vim.schedule(function()
		if vim.api.nvim_get_current_win() == winid and vim.api.nvim_get_current_buf() == bufnr then
			vim.cmd.startinsert()
		end
	end)
end

return M
