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

	local timer = duration
	local minutes, seconds

	countdown_job_id = vim.fn.jobstart({
		"sh",
		"-c",
		string.format([[sleep %ds && echo 'Countdown: Time is up!']], duration),
	})

	vim.fn.chansend(countdown_job_id, "exit\n")

	vim.fn.jobwait([[
    function(job_id, data, event)
      if event == "exit" then
        vim.api.nvim_feedkeys(":echo 'Countdown: Time is up!'", "n", true)
      end
    endfunction
  ]])
end

return M -- countdown.lua
