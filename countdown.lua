-- countdown.lua

local M = {}
local countdown_job_id

function M.setup()
	-- Setup code for the plugin (if needed)
end

function M.countdown(duration)
	if countdown_job_id then
		print("Countdown is already running. Please wait for the current countdown to finish.")
		return
	end

	countdown_job_id = vim.fn.jobstart({
		"sh",
		"-c",
		string.format([[sleep %ds && echo 'Countdown: Time is up!']], duration),
	})

	vim.fn.chansend(countdown_job_id, "exit\n")

	vim.defer_fn(function()
		while vim.fn.jobwait(countdown_job_id, 0) == -1 do
			-- Waiting for the countdown job to finish
		end

		countdown_job_id = nil
		vim.cmd("echo 'Countdown: Time is up!'")
	end, 0)
end

return M
