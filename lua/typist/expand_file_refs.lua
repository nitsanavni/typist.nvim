-- expand_file_refs.lua

local filepath_utils = require("typist.filepath_utils")
local vim = vim -- Ensure 'vim' is available

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

-- Function to execute a script and capture its output and exit status
local function execute_script(path)
	local cmd = path
	local output = vim.fn.systemlist(cmd)
	local exit_status = vim.v.shell_error
	return table.concat(output, "\n"), exit_status
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

	-- Pattern to match @ or @! followed by a valid file path
	local pattern = "@(!?)([%w%-%_%./]+)"

	-- Replace each occurrence of @filepath with the file contents if the file exists
	local expanded = query:gsub(pattern, function(execute_flag, filepath)
		-- Resolve the full path considering additional search paths
		local resolved_path = filepath_utils.resolve_filepath(filepath, search_paths)

		if resolved_path then
			local content = read_file(resolved_path)
			if content then
				-- Escape backticks in content to prevent Markdown issues
				content = content:gsub("`", "\\`")
				local ends_with_newline = content:sub(-1) == "\n"
				local last_char = ends_with_newline and "" or "\n"
				local result = "## File: `" .. filepath .. "`\n\n```\n" .. content .. last_char .. "```\n"

				if execute_flag == "!" then
					-- Attempt to execute the script and capture its output
					local output, exit_status = execute_script(resolved_path)
					if output then
						-- Escape backticks in output
						output = output:gsub("`", "\\`")
						result = result .. "\n### Output of `" .. filepath .. "`\n\n```\n" .. output .. "\n```\n"
					end
					if exit_status ~= 0 then
						result = result .. "\n**Script exited with status " .. exit_status .. "**\n"
					end
				end
				return result
			end
		end
		-- If file doesn't exist or can't be read, leave the original @filepath
		return "@" .. (execute_flag or "") .. filepath
	end)

	return expanded
end

return expand_file_refs
