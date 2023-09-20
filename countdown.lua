-- countdown.lua

local M = {}

function M.setup(config)
	-- Setup code for the plugin (if needed)
end

function M.countdown(duration)
	local timer = duration
	local minutes, seconds

	while timer >= 0 do
		minutes = string.format("%02d", math.floor(timer / 60))
		seconds = string.format("%02d", timer % 60)

		vim.cmd("echo 'Countdown: " .. minutes .. ":" .. seconds .. "'")
		vim.cmd("sleep 1000m")

		timer = timer - 1
	end

	vim.cmd("echo 'Countdown: Time is up!'")
end

return M
