-- expand_file_refs.lua

local expand_file_refs = {}

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
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

-- Main function to expand file references in the query string
-- @param query (string): The multi-line string containing @filepath references
-- @return (string): The expanded string with file contents inserted
function expand_file_refs.expand_file_refs(query)
    if type(query) ~= "string" then
        error("Expected a string for 'query'")
    end

    -- Pattern to match @ followed by a valid file path (assuming filenames without spaces)
    local pattern = "@([%w%-%_%.]+)"

    -- Replace each occurrence of @filepath with the file contents if the file exists
    local expanded = query:gsub(pattern, function(filepath)
        if file_exists(filepath) then
            local content = read_file(filepath)
            if content then
                -- Escape backticks in content to prevent Markdown issues
                content = content:gsub("`", "\\`")
                return "```\n" .. content .. "\n```"
            end
        end
        -- If file doesn't exist or can't be read, leave the original @filepath
        return "@" .. filepath
    end)

    return expanded
end

return expand_file_refs
