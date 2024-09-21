-- expand_file_refs.lua

local filepath_utils = require("typist.filepath_utils")

-- Utility function to read the entire contents of a file
local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()
	return content
end

-- Main function to expand file references in the query string
-- @param query (string): The multi-line string containing @filepath references
-- @param search_paths (table, optional): Additional directories to search for relative file paths
-- @return (string): The expanded string with file contents inserted
local function expand_file_refs(query, search_paths)
	if type(query) ~= "string" then
		error("Expected a string for 'query'")
	end

	-- Default to an empty table if search_paths is not provided
	search_paths = search_paths or {}

	-- Pattern to match @ followed by a valid file path (assuming filenames without spaces)
	local pattern = "@([%w%-%_%./]+)"

	-- Replace each occurrence of @filepath with the file contents if the file exists
	local expanded = query:gsub(pattern, function(filepath)
		-- Resolve the full path considering additional search paths
		local resolved_path = filepath_utils.resolve_filepath(filepath, search_paths)

		if resolved_path then
			local content = read_file(resolved_path)
			if content then
				-- Escape backticks in content to prevent Markdown issues
				content = content:gsub("`", "\\`")
				local ends_with_newline = content:sub(-1) == "\n"
				local last_char = ends_with_newline and "" or "\n"
				return "## File: `" .. filepath .. "`\n\n```\n" .. content .. last_char .. "```\n"
			end
		end
		-- If file doesn't exist or can't be read, leave the original @filepath
		return "@" .. filepath
	end)

	return expanded
end

return expand_file_refs
