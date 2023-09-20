-- countdown.lua

local notify = require("notify")
local M = {}

function M.countdown(seconds)
	local countdown_job_id
	local remaining = seconds

	-- Function to update the countdown notification
	local function update_notification()
		notify("Countdown: " .. tostring(remaining) .. " seconds remaining", {
			title = "Countdown",
			timeout = 0,
		})
	end

	-- Function to handle the terminal job exit
	local function on_exit(job_id, _, _)
		if job_id == countdown_job_id then
			countdown_job_id = nil
			notify("Countdown: Time is up!", {
				title = "Countdown",
				timeout = 0,
			})
		end
	end

	-- Start the countdown job in a new terminal window
	local function start_countdown_terminal()
		vim.cmd("terminal")
		vim.cmd("startinsert")
		countdown_job_id = vim.fn.termopen({
			"sh",
			"-c",
			[[for ((s=]] .. seconds .. [[; s>=0; s--)); do
          printf "Countdown: %02d seconds remaining\n" $s
          sleep 1
      done]],
		})
		vim.fn.termwait(countdown_job_id)
	end

	-- Start the countdown
	local function start_countdown()
		update_notification()
		vim.defer_fn(start_countdown_terminal, 0)
	end

	-- Function to be called from Neovim command-line
	function countdown(args)
		local seconds = tonumber(args)
		if seconds then
			remaining = seconds
			start_countdown()
		else
			print("Invalid argument. Please provide the countdown duration in seconds.")
		end
	end

	-- Setup the on_exit autocommand to handle terminal job exit
	vim.cmd([[
    autocmd! CountdownTerminalExit
    autocmd TermClose * call v:lua.require'countdown'.on_exit(v:eventjobid, v:eventstatus, v:eventretval)
  ]])

	return M
end

return M
