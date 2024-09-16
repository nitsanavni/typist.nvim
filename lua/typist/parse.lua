local M = {}

function M.parse_response(response)
	local files = {}
	for file_name, content in response:gmatch("### File: `(.-)`%s*```%s*(.-)%s*```") do
		table.insert(files, {
			name = file_name,
			content = content,
		})
	end
	return files
end

return M
