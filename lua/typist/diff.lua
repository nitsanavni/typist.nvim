local M = {}

function M.process_response(response)
	local files = require("typist.parse").parse_response(response)

	for _, file in ipairs(files) do
		local tmpfile = "/tmp/typist_" .. vim.fn.sha1(file.name) .. ".tmp"
		local f = io.open(tmpfile, "w")
		f:write(file.content)
		f:close()

		vim.cmd("tabnew " .. tmpfile)
		vim.cmd("edit " .. file.name)
	end
end

return M
