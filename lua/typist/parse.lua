local function parse_response(response)
	local files = {}
	for file_name, content in response:gmatch("## File: `([^`]+)`%s*```%w*%s*([%s%S]-)%s*```") do
		table.insert(files, {
			name = file_name,
			content = content,
		})
	end
	return files
end

return parse_response
