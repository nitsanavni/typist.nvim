local M = {}

local additional_paths = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local current_file_path = vim.api.nvim_buf_get_name(bufnr)
	local current_file_dir = vim.fn.fnamemodify(current_file_path, ":h")
	return { current_file_dir }
end

local curren_buffer_contents = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	return table.concat(lines, "\n")
end

-- @./my-example-file
M.expand_file_refs_in_current_buf = function()
	local contents = curren_buffer_contents()
	local expanded = require("typist.expand_file_refs")(contents, additional_paths())

	local expanded_lines = vim.split(expanded, "\n")

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, expanded_lines)
end

M.prepare_prompt_from_current_buf = function()
	local contents = curren_buffer_contents()

	local prepare_prompt = require("typist.prepare_prompt")(contents)

	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(prepare_prompt, "\n"))
end

M.call_open_ai_with_current_buffer = function()
	local contents = curren_buffer_contents()

	local response = require("typist.api")(contents)

	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(response, "\n"))
end

local pretty_print = function(tbl, indent)
	if not indent then
		indent = 0
	end
	local toprint = string.rep(" ", indent) .. "{\n"
	indent = indent + 2
	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent)
		if type(k) == "number" then
			toprint = toprint .. "[" .. k .. "] = "
		elseif type(k) == "string" then
			toprint = toprint .. k .. "= "
		end
		if type(v) == "number" then
			toprint = toprint .. v .. ",\n"
		elseif type(v) == "string" then
			toprint = toprint .. '"' .. v .. '",\n'
		elseif type(v) == "table" then
			toprint = toprint .. pretty_print(v, indent + 2) .. ",\n"
		else
			toprint = toprint .. '"' .. tostring(v) .. '",\n'
		end
	end
	indent = indent - 2
	toprint = toprint .. string.rep(" ", indent) .. "}"
	return toprint
end

M.up_to_parse = function()
	local contents = curren_buffer_contents()

	local expanded = require("typist.expand_file_refs")(contents, additional_paths())
	local prepare_prompt = require("typist.prepare_prompt")(expanded)
	local response = require("typist.api")(prepare_prompt)
	local parsed = require("typist.parse")(response, additional_paths())
	print(pretty_print(parsed))
end

M.setup = function()
	vim.api.nvim_create_user_command("TypistExpand", M.expand_file_refs_in_current_buf, {})
	vim.api.nvim_create_user_command("TypistPreparePrompt", M.prepare_prompt_from_current_buf, {})
	vim.api.nvim_create_user_command("TypistCallOpenAi", M.call_open_ai_with_current_buffer, {})
	vim.api.nvim_create_user_command("TypistParsed", M.up_to_parse, {})
end

return M
