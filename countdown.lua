-- countdown.lua

local M = {}
local countdown_job_id
local countdown_win_id

function M.setup()
	-- Setup code for the plugin (if needed)
end

function M.countdown(duration)
	if countdown_job_id then
		print("Countdown is already running. Please wait for the current countdown to finish.")
		return
	end

	local width = 20
	local height = 2

	-- Open the float terminal at the bottom right of the screen
	local buf_id = vim.api.nvim_create_buf(false, true)
	countdown_win_id = vim.api.nvim_open_win(buf_id, true, {
		relative = "editor",
		width = width,
		height = height,
		row = vim.o.lines - height,
		col = vim.o.columns - width,
		style = "minimal",
		border = "single",
	})

	countdown_job_id = vim.fn.jobstart({
		"sh",
		"-c",
		string.format(
			[[for i in $(seq %d -1 1); do echo "Countdown: $i seconds remaining"; sleep 1; done; echo 'Countdown: Time is up!']],
			duration
		),
	}, {
		on_stdout = function(_, data)
			vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, data)
		end,
		on_exit = function()
			countdown_job_id = nil
			vim.cmd("echo 'Countdown: Time is up!'")
			vim.api.nvim_buf_set_option(buf_id, "modifiable", false)

			-- Show "Countdown done" at specific time after countdown is complete
			local specific_time = os.date("%H:%M:%S", os.time() + 10) -- Change the time interval as needed
			vim.defer_fn(function()
				vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, { "Countdown done at " .. specific_time })
			end, 0)
		end,
	})
end

return M
