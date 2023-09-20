-- countdown.lua

local M = {}

function M.countdown(seconds)
	local remaining = seconds

	local function display_message()
		vim.cmd("vertical belowright new")
		vim.cmd("setlocal buftype=nofile")
		vim.cmd("setlocal bufhidden=wipe")
		vim.cmd("setlocal noswapfile")
		vim.cmd("setlocal nowrap")
		vim.cmd("setlocal nolist")
		vim.cmd("setlocal nonumber")

		for i = remaining, 0, -1 do
			vim.api.nvim_buf_set_lines(0, -1, -1, false, { "Countdown: " .. i .. " seconds remaining" })
			vim.wait(1000, function()
				return vim.api.nvim_buf_line_count(0) == i + 1
			end)
		end

		vim.cmd("q")
	end

	vim.schedule(display_message)
end

-- Function to be called from Neovim command-line
function countdown(args)
	local seconds = tonumber(args)
	if seconds then
		M.countdown(seconds)
	else
		print("Invalid argument. Please provide the countdown duration in seconds.")
	end
end

return M
