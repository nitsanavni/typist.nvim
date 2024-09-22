local function call_openai(prompt, model)
	local api_key = os.getenv("OPENAI_API_KEY")

	if not api_key then
		error("OPENAI_API_KEY environment variable is not set")
	end

	model = model or "gpt-4o-mini" -- Default model

	local url = "https://api.openai.com/v1/chat/completions"

	local payload = {
		model = model,
		messages = {
			{
				role = "user",
				content = prompt,
			},
		},
		max_tokens = 4096, -- Updated max_tokens to 4096
	}

	local data = vim.fn.json_encode(payload)

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

	local decoded_response = vim.fn.json_decode(response)

	if decoded_response.error then
		error("OpenAI API Error: " .. decoded_response.error.message)
	end

	return decoded_response.choices[1].message.content
end

return call_openai
