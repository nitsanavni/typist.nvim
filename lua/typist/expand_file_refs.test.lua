-- expand_file_refs.test.lua

local expand_file_refs = require("expand_file_refs")

-- Example query string
local query = [[
@my-example-file

how many words in this file?
]]

-- Expand file references
local expanded_query = expand_file_refs(query)

print(expanded_query)
