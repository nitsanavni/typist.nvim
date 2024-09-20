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

M.prepare_prompt_from_current_buf = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local contents = table.concat(lines, "\n")

	local prepare_prompt = require("typist.prepare_prompt")(contents)

	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(prepare_prompt, "\n"))
end

M.setup = function()
	vim.api.nvim_create_user_command("TypistExpand", M.expand_file_refs_in_current_buf, {})
	vim.api.nvim_create_user_command("TypistPreparePrompt", M.prepare_prompt_from_current_buf, {})
end

return M
