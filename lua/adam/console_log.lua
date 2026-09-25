local M = {}

local function is_path(text)
	if not text or not text:match("^[%a_$][%w_$.]*$") or text:sub(-1) == "." then
		return false
	end

	for part in text:gmatch("[^.]+") do
		if not part:match("^[%a_$][%w_$]*$") then
			return false
		end
	end

	return not text:find("..", 1, true)
end

local function expression_at_cursor(bufnr, row, col)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok then
		return nil, nil
	end

	if not pcall(parser.parse, parser) then
		return nil, nil
	end

	local node_ok, node = pcall(vim.treesitter.get_node, {
		bufnr = bufnr,
		pos = { row - 1, col },
	})
	if not node_ok then
		return nil, nil
	end

	local expression
	local in_jsx = false
	while node do
		local kind = node:type()
		if kind:match("^jsx_") then
			in_jsx = true
		end
		if kind == "identifier" or kind == "member_expression" or kind == "this" then
			local text = vim.treesitter.get_node_text(node, bufnr)
			if is_path(text) then
				expression = text
			end
		end
		node = node:parent()
	end

	return expression, in_jsx
end

function M.insert()
	local bufnr = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local expression, in_jsx = expression_at_cursor(bufnr, row, col)

	if in_jsx then
		vim.notify("Cannot insert console.log inside JSX markup", vim.log.levels.WARN)
		return
	end
	if in_jsx == nil and vim.bo[bufnr].filetype:match("react$") then
		vim.notify("Cannot insert console.log: JSX parser unavailable", vim.log.levels.WARN)
		return
	end

	local indent = line:match("^[ \t]*")
	local log = expression and string.format('console.log("%s:", %s);', expression, expression) or "console.log();"
	vim.api.nvim_buf_set_lines(bufnr, row, row, false, { indent .. log })
	vim.api.nvim_win_set_cursor(0, { row + 1, #indent + (expression and 0 or #"console.log(") })
end

return M
