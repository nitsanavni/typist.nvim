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

local write_to_buffer = function(contents)
	local bufnr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(contents, "\n"))
end

-- @./my-example-file
M.expand_file_refs_in_current_buf = function()
	local contents = curren_buffer_contents()
	local expanded = require("typist.expand_file_refs")(contents, additional_paths())

	write_to_buffer(expanded)
end

M.prepare_prompt_from_current_buf = function()
	local contents = curren_buffer_contents()

	local prepare_prompt = require("typist.prepare_prompt")(contents)

	write_to_buffer(prepare_prompt)
end

M.call_open_ai_with_current_buffer = function()
	local contents = curren_buffer_contents()

	local response = require("typist.api")(contents)

	write_to_buffer(response)
end

local function pretty_print(tbl, indent)
	indent = indent or 0
	local toprint = string.rep(" ", indent) .. "{\n"
	indent = indent + 2
	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent) .. (type(k) == "number" and "[" .. k .. "] = " or k .. "= ")
		if type(v) == "table" then
			toprint = toprint .. pretty_print(v, indent) .. ",\n"
		else
			toprint = toprint .. (type(v) == "string" and '"' .. v .. '"' or tostring(v)) .. ",\n"
		end
	end
	return toprint .. string.rep(" ", indent - 2) .. "}"
end

M.up_to_parse = function()
	local contents = curren_buffer_contents()

	local expanded = require("typist.expand_file_refs")(contents, additional_paths())
	local prepare_prompt = require("typist.prepare_prompt")(expanded)
	local response = require("typist.api")(prepare_prompt)
	local parsed = require("typist.parse")(response, additional_paths())
	write_to_buffer(pretty_print(parsed))
end

M.typist = function()
	local contents = curren_buffer_contents()

	local expanded = require("typist.expand_file_refs")(contents, additional_paths())
	local prepare_prompt = require("typist.prepare_prompt")(expanded)
	local response = require("typist.api")(prepare_prompt)
	local parsed = require("typist.parse")(response, additional_paths())
	local parsed_files = parsed

	for _, file in ipairs(parsed_files) do
		-- Open a new tab for each file
		vim.cmd("tabnew")

		-- Create a buffer for the parsed content
		local buf_parsed = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(buf_parsed, 0, -1, false, vim.split(file.content, "\n"))

		-- Set the left window to display the parsed content
		vim.cmd("leftabove vnew")
		vim.api.nvim_win_set_buf(0, buf_parsed)

		-- Open the file in diff mode on the right
		if file.path and vim.fn.filereadable(file.path) == 1 then
			vim.cmd("rightbelow vert diffsplit " .. file.path)
		else
			vim.cmd("rightbelow vert diffsplit " .. file.name)
		end
	end
end

M.setup = function()
	vim.api.nvim_create_user_command("TypistExpand", M.expand_file_refs_in_current_buf, {})
	vim.api.nvim_create_user_command("TypistPreparePrompt", M.prepare_prompt_from_current_buf, {})
	vim.api.nvim_create_user_command("TypistCallOpenAi", M.call_open_ai_with_current_buffer, {})
	vim.api.nvim_create_user_command("TypistParsed", M.up_to_parse, {})
	vim.api.nvim_create_user_command("Typist", M.typist, {})
end

return M
