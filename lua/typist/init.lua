local M = {}

function M.open_prompt_buffer()
	vim.cmd("enew") -- create a new buffer
	vim.bo.filetype = "typist_prompt"
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Enter your prompt here:" })
	vim.api.nvim_buf_set_keymap(
		0,
		"n",
		"<CR>",
		':lua require("typist").process_prompt()<CR>',
		{ noremap = true, silent = true }
	)
end

function M.process_prompt()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local prompt = table.concat(lines, "\n")

	local response = require("typist.api").call_openai(prompt)
	require("typist.diff").process_response(response)
end

vim.api.nvim_create_user_command("Typist", M.open_prompt_buffer, {})

return M
