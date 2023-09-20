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

		-- Create the floating terminal
		local term_buf = vim.api.nvim_create_buf(false, true)
		local term_win = vim.api.nvim_open_win(term_buf, true, {
			relative = "editor",
			row = term_row,
			col = term_col,
			width = term_width,
			height = term_height,
			style = "minimal",
			border = "single",
		})

		-- Set terminal buffer options
		vim.fn.setbufvar(term_buf, "&buftype", "terminal")
		vim.fn.setbufvar(term_buf, "&bufhidden", "hide")
		vim.fn.setbufvar(term_buf, "&swapfile", false)
		vim.fn.setbufvar(term_buf, "&filetype", "terminal")

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
		vim.api.nvim_win_close(term_win, true)
	end

	vim.schedule_wrap(display_message)()
end

-- Function to be called from Neovim command-line
function M.setup()
	vim.cmd([[
    command! -nargs=1 Countdown lua require('countdown').countdown(<args>)
  ]])
end

return M
