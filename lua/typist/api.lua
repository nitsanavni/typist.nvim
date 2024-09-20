local function call_openai(prompt)
	-- Retrieve the OpenAI API key from environment variables
	local api_key = os.getenv("OPENAI_API_KEY")

	if not api_key then
		error("OPENAI_API_KEY environment variable is not set")
	end

	-- Define the API endpoint for chat completions
	local url = "https://api.openai.com/v1/chat/completions"

	-- Construct the payload with the required structure
	local payload = {
		model = "gpt-4o-mini",
		messages = {
			{
				role = "user",
				content = prompt,
			},
		},
		max_tokens = 10000,
	}

	-- Encode the payload to JSON
	local data = vim.fn.json_encode(payload)

	-- Make the API request using curl
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

	-- Decode the JSON response
	local decoded_response = vim.fn.json_decode(response)

	-- Error handling for API response
	if decoded_response.error then
		error("OpenAI API Error: " .. decoded_response.error.message)
	end

	-- Extract and return the assistant's reply
	return decoded_response.choices[1].message.content
end

return call_openai
