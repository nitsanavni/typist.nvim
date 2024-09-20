local M = {}

-- @./my-example-file

M.expand_file_refs_in_current_buf = function()
	print("Expanding file references in the current buffer")

	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local contents = table.concat(lines, "\n")

	local expanded = require("typist.expand_file_refs")(contents)

	local expanded_lines = vim.split(expanded, "\n")

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, expanded_table)
end

M.setup = function()
	vim.api.nvim_create_user_command("TypistExpand", M.expand_file_refs_in_current_buf, {})
end

return M
