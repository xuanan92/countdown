-- countdown.lua

local M = {}

local remaining = 0
local timer = nil

function M.countdown(seconds)
	remaining = seconds

	if timer then
		timer:stop()
		timer:close()
		timer = nil
	end

	timer = vim.loop.new_timer()
	timer:start(
		1000,
		1000,
		vim.schedule_wrap(function()
			if remaining > 0 then
				remaining = remaining - 1
				vim.api.nvim_set_var("countdown_time", remaining)
			else
				timer:stop()
				timer:close()
				timer = nil
			end
		end)
	)
end

function M.setup()
	vim.api.nvim_exec(
		[[
    augroup CountdownStatusline
      autocmd!
      autocmd User Statusline * call v:lua.require'countdown'.update_statusline()
    augroup END
  ]],
		false
	)
end

function M.update_statusline()
	local remaining = vim.api.nvim_get_var("countdown_time")
	if remaining then
		vim.api.nvim_command(
			'let &statusline = "%#StatusLine# Countdown: " . ' .. remaining .. ' . " seconds remaining "'
		)
	end
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
