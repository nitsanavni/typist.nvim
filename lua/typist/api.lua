local M = {}

function M.call_openai(prompt)
	local api_key = os.getenv("OPENAI_API_KEY")
	local url = "https://api.openai.com/v1/completions"
	local data = vim.fn.json_encode({
		model = "text-davinci-003",
		prompt = prompt,
		max_tokens = 150,
	})

	local response = vim.fn.system({
		"curl",
		"-s",
		"-X",
		"POST",
		url,
		"-H",
		"Content-Type: application/json",
		"-H",
		"Authorization: Bearer " .. api_key,
		"-d",
		data,
	})

	return vim.fn.json_decode(response).choices[1].text
end

return M
