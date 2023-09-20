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

-- Define the custom command
vim.cmd([[command! -nargs=1 Countdown lua start_countdown(<args>)]])
