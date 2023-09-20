local function open_float_terminal()
	-- Set the terminal dimensions
	local width = 40
	local height = 1

	-- Calculate the terminal window position
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	-- Open the terminal in a floating window
	vim.cmd(string.format("terminal ++curwin ++rows=%d ++cols=%d ++row=%d ++col=%d", height, width, row, col))
end

local function start_countdown(time)
	-- Check if the time is a valid number
	local countdown_time = tonumber(time)
	if countdown_time == nil then
		print("Invalid countdown time")
		return
	end

	-- Start the countdown
	for i = countdown_time, 0, -1 do
		-- Clear the screen
		vim.cmd("redraw")

		-- Print the countdown value
		print("Countdown: " .. i)

		-- Wait for 1 second
		vim.cmd("sleep 1000m")
	end

	-- Open the floating terminal
	open_float_terminal()
end

local function countdown_prompt()
	-- Prompt the user for the countdown time
	vim.fn.inputsave()
	local countdown_time = vim.fn.input("Enter countdown time (in seconds): ")
	vim.fn.inputrestore()

	-- Start the countdown
	start_countdown(countdown_time)
end

-- Create a key mapping to trigger the countdown prompt
vim.api.nvim_set_keymap("n", "<Leader>c", "<Cmd>lua countdown_prompt()<CR>", { noremap = true, silent = true })
