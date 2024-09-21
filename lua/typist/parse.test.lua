local expand_file_refs = require("expand_file_refs")
local parse_response = require("parse")

local query = [[
hello
@my-example-file
mellow
@./example-file-2
@./example-file-2

how many words in this file?
]]

local expanded_query = expand_file_refs(query)

local function pretty_print(tbl, indent)
	indent = indent or 0
	local space = string.rep(" ", indent)

	for k, v in pairs(tbl) do
		if type(v) == "table" then
			print(space .. tostring(k) .. ":")
			pretty_print(v, indent + 2)
		else
			print(space .. tostring(k) .. ": " .. tostring(v))
		end
	end
end

pretty_print(parse_response(expanded_query))
