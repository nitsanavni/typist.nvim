-- prepare_prompt.lua

local function prepare_prompt(query)
	return [[
for files that need modifications:
1. rewrite the whole file with the modifications
2. use the following format:
changes required: {think}
### File: `{file}`

```{language}
{code}
```

3. no line numbers

multiple files are allowed.
no need to repeat unchanged files.
speak freely outside of code blocks.

request:
]] .. query
end

return prepare_prompt
