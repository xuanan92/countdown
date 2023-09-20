-- countdown.lua

local M = {}

function M.countdown(seconds)
	local remaining = seconds

	local function display_message()
		local term_width = 50
		local term_height = 1

		-- Calculate the floating terminal position
		local term_row = vim.o.lines - term_height - 1
		local term_col = vim.o.columns - term_width

		-- Open a new terminal window
		vim.cmd("botright vsplit term://bash")

		-- Resize the terminal window
		vim.cmd(term_height .. "wincmd _")
		vim.cmd(term_width .. "wincmd |")

		-- Move the terminal window to the desired position
		vim.cmd("wincmd J")
		vim.cmd(term_row .. "wincmd _")
		vim.cmd(term_col .. "wincmd |")

		-- Start the countdown
		for i = remaining, 0, -1 do
			vim.fn.termopen("echo Countdown: " .. i .. " seconds remaining")

			-- Allow editing the text while counting down
			vim.cmd("startinsert")
			vim.cmd("autocmd InsertLeave <buffer> stopinsert")

			-- Wait for 1 second
			vim.wait(1000)
		end

		-- Close the terminal window
		vim.cmd("q!")
	end

	vim.schedule(display_message)
end

-- Function to be called from NeoVim command-line
function M.setup()
	vim.cmd([[
    command! -nargs=1 Countdown lua require('countdown').countdown(<args>)
  ]])
end

return M
