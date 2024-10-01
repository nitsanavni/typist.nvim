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

M.call_open_ai_with_current_buffer = function(model)
	local contents = curren_buffer_contents()
	local response = require("typist.api")(contents, model)
	write_to_buffer(response)
end

M.typist = function(model)
	local expanded = require("typist.expand_file_refs")(curren_buffer_contents(), additional_paths())
	local prepare_prompt = require("typist.prepare_prompt")(expanded)
	local response = require("typist.api")(prepare_prompt, model)
	local parsed = require("typist.parse")(response, additional_paths())
	local parsed_files = parsed

	for _, file in ipairs(parsed_files) do
		vim.cmd("tabnew")

		local buf_parsed = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_lines(buf_parsed, 0, -1, false, vim.split(file.content, "\n"))

		if file.path and vim.fn.filereadable(file.path) == 1 then
			vim.cmd("rightbelow vert diffsplit " .. file.path)
		else
			vim.cmd("rightbelow vert diffsplit " .. file.name)
		end

		vim.cmd("wincmd h")
	end
end

local function get_diff_buffers()
	local left_win = vim.fn.win_getid(vim.fn.winnr("h"))
	local right_win = vim.fn.win_getid(vim.fn.winnr("l"))
	local left_buf = vim.api.nvim_win_get_buf(left_win)
	local right_buf = vim.api.nvim_win_get_buf(right_win)
	return left_buf, right_buf
end

M.approve_current_diff = function()
	local left_bufnr, right_bufnr = get_diff_buffers()

	if right_bufnr then
		local filename = vim.api.nvim_buf_get_name(right_bufnr)
		local left_contents = vim.api.nvim_buf_get_lines(left_bufnr, 0, -1, false)
		vim.api.nvim_buf_set_lines(right_bufnr, 0, -1, false, left_contents)
		vim.api.nvim_buf_call(right_bufnr, function()
			vim.cmd("w")
		end)
		vim.cmd("tabclose")
		vim.notify(filename .. " updated")
	end
end

M.listen = function(files)
	local bufnr = vim.api.nvim_create_buf(false, true)
	local lines = {}
	for _, file in ipairs(files) do
		table.insert(lines, "@" .. file)
	end
	table.insert(lines, "")

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_win_set_cursor(0, { #lines, 0 })
end

local function custom_completion(arg_lead, cmd_line, cursor_pos)
	-- Your list of custom completions
	local completions = { "gpt-4o-mini", "gpt-4o-2024-08-06", "o1-mini" }
	local filtered = {}

	for _, completion in ipairs(completions) do
		if completion:match(arg_lead) then
			table.insert(filtered, completion)
		end
	end

	return filtered
end

M.setup = function()
	vim.api.nvim_create_user_command("TypistCallOpenAi", function(opts)
		M.call_open_ai_with_current_buffer(opts.args)
	end, { nargs = 1 })

	vim.api.nvim_create_user_command("TypistProcessRequest", function(opts)
		local args = opts.args ~= "" and opts.args or "gpt-4o-2024-08-06"
		M.typist(args)
	end, { nargs = "?", complete = custom_completion })

	vim.api.nvim_create_user_command("TypistListen", function(opts)
		M.listen(opts.fargs)
	end, { nargs = "*", complete = "file" })

	vim.api.nvim_create_user_command("TypistApproveCurrentDiff", M.approve_current_diff, {})
end

return M
