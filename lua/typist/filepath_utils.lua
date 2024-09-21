-- filepath_utils.lua

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

-- Expose the functions as part of the module
local filepath_utils = {
    file_exists = file_exists,
    resolve_filepath = resolve_filepath
}

return filepath_utils
