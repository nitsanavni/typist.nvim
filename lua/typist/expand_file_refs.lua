-- expand_file_refs.lua

-- Utility function to check if a file exists
local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    else
        return false
    end
end

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

-- Utility function to resolve the full path of a file given additional search paths
-- @param filepath (string): The relative or absolute file path
-- @param search_paths (table): A list of directories to search in
-- @return (string or nil): The resolved full path if found, otherwise nil
local function resolve_filepath(filepath, search_paths)
    -- If the filepath is absolute and exists, return it
    if filepath:match("^/") and file_exists(filepath) then
        return filepath
    end

    -- Iterate through each search path to find the file
    for _, dir in ipairs(search_paths) do
        -- Ensure the directory path ends with a '/'
        local normalized_dir = dir:match(".+/$") and dir or dir .. "/"
        local full_path = normalized_dir .. filepath
        if file_exists(full_path) then
            return full_path
        end
    end

    -- As a fallback, check the filepath as-is
    if file_exists(filepath) then
        return filepath
    end

    -- File not found in any of the search paths
    return nil
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
        local resolved_path = resolve_filepath(filepath, search_paths)

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
