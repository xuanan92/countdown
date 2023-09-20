-- countdown.lua

local notify = require("notify")
local M = {}

function M.countdown(seconds)
	local remaining = seconds

	local function update_notification()
		notify("Countdown: " .. tostring(remaining) .. " seconds remaining", {
			title = "Countdown",
			timeout = 0,
		})
	end

	local function finish_notification()
		notify("Countdown: Time is up!", {
			title = "Countdown",
			timeout = 0,
		})
	end

	local function countdown_loop()
		if remaining > 0 then
			update_notification()
			remaining = remaining - 1
			vim.defer_fn(countdown_loop, 1000) -- Schedule the next iteration after 1 second
		else
			finish_notification()
		end
	end

	countdown_loop()
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
