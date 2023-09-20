-- countdown.lua

local notify = require("notify")
local M = {}
local countdown_job_id

function M.setup()
	-- Setup code for the plugin (if needed)
end

function M.countdown(seconds)
	if countdown_job_id then
		print("Countdown is already running. Please wait for the current countdown to finish.")
		return
	end

	countdown_job_id = vim.fn.jobstart({
		"sh",
		"-c",
		[[for ((s=]] .. seconds .. [[; s>=0; s--)); do
        printf "Countdown: %02d seconds remaining\n" $s
        sleep 1
    done
    echo 'Countdown: Time is up!']],
	}, {
		on_stdout = function(_, data)
			local output = table.concat(data, "\n")
			notify(output, { title = "Countdown", timeout = 0 })
		end,
		on_exit = function()
			countdown_job_id = nil
			notify("Time is up!", { title = "Countdown", timeout = 0 })
		end,
	})
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
