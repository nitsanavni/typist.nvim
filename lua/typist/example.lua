-- Example Lua script for typist

-- Function to print a greeting
function greet(name)
	print("Hello, " .. name .. "!")
end

-- Call the greet function
greet("World")

-- Loop to print numbers from 1 to 5
for i = 1, 5 do
	print("Number: " .. i)
end

-- Table to store names
names = { "Alice", "Bob", "Charlie" }

-- Loop through and print each name
for _, name in ipairs(names) do
	print("Name: " .. name)
end
