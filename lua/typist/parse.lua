local filepath_utils = require("typist.filepath_utils")

local function parse_response(response, search_paths)
	search_paths = search_paths or {}
	local files = {}
	for file_name, content in response:gmatch("## File: `([^`]+)`%s*```%w*%s*([%s%S]-)%s*```") do
		local resolved_path = filepath_utils.resolve_filepath(file_name, search_paths)
		table.insert(files, {
			name = file_name,
			content = content,
			path = resolved_path,
		})
	end
	return files
end

return parse_response
