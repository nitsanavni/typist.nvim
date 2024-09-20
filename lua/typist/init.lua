local M = {}

M.expand_file_refs_in_current_buf = function()
	print("Expanding file references in the current buffer")
end

M.setup = function()
	vim.api.nvim_create_user_command("Typist.expand_file_refs_in_current_buf", M.expand_file_refs_in_current_buf, {})
end

return M
