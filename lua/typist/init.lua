local M = {}

-- @./my-example-file

M.expand_file_refs_in_current_buf = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local contents = table.concat(lines, "\n")

	local current_file_path = vim.api.nvim_buf_get_name(bufnr)
	local current_file_dir = vim.fn.fnamemodify(current_file_path, ":h")
	local additional_paths = { current_file_dir }

	local expanded = require("typist.expand_file_refs")(contents, additional_paths)

	local expanded_lines = vim.split(expanded, "\n")

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, expanded_lines)
end

M.setup = function()
	vim.api.nvim_create_user_command("TypistExpand", M.expand_file_refs_in_current_buf, {})
end

return M
