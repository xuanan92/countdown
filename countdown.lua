local M = {}
local countdown_job_id
local countdown_win_id

function M.setup()
	-- Setup code for the plugin (if needed)
end

function M.countdown(duration)
	if countdown_job_id then
		-- If a countdown is already running, stop the current countdown
		vim.fn.jobstop(countdown_job_id)
		vim.api.nvim_win_close(countdown_win_id, true)
		countdown_job_id = nil
	end

	local width = 50
	local height = 1

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
		on_exit = function(_, _)
			countdown_job_id = nil
			vim.cmd("echo 'Countdown: Time is up!'")
			vim.api.nvim_buf_set_option(buf_id, "modifiable", false)

			-- Close the float terminal after 3 seconds
			vim.defer_fn(function()
				vim.api.nvim_win_close(countdown_win_id, true)
				M.beep() -- Call the beep function
			end, 0)
		end,
	})
end

function M.beep()
	if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
		-- Windows
		os.execute('powershell -c "[console]::beep(500, 100)"')
	else
		-- Linux or Unix-like systems
		os.execute("paplay --volume=32768 --channels=1 --rate=8000 /dev/zero")
	end
end

return M
-- local M = {}
-- local countdown_job_id
-- local countdown_win_id
--
-- function M.setup()
-- 	-- Setup code for the plugin (if needed)
-- end
--
-- function M.countdown(duration)
-- 	if countdown_job_id then
-- 		print("Countdown is already running. Please wait for the current countdown to finish.")
-- 		return
-- 	end
--
-- 	local width = 50
-- 	local height = 1
--
-- 	-- Open the float terminal at the bottom right of the screen
-- 	local buf_id = vim.api.nvim_create_buf(false, true)
-- 	countdown_win_id = vim.api.nvim_open_win(buf_id, true, {
-- 		relative = "editor",
-- 		width = width,
-- 		height = height,
-- 		row = vim.o.lines - height,
-- 		col = vim.o.columns - width,
-- 		style = "minimal",
-- 		border = "single",
-- 	})
--
-- 	countdown_job_id = vim.fn.jobstart({
-- 		"sh",
-- 		"-c",
-- 		string.format(
-- 			[[for i in $(seq %d -1 1); do echo "Countdown: $i seconds remaining"; sleep 1; done; echo 'Countdown: Time is up!']],
-- 			duration
-- 		),
-- 	}, {
-- 		on_stdout = function(_, data)
-- 			vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, data)
-- 		end,
-- 		on_exit = function(_, _)
-- 			countdown_job_id = nil
-- 			vim.cmd("echo 'Countdown: Time is up!'")
-- 			vim.api.nvim_buf_set_option(buf_id, "modifiable", false)
--
-- 			-- Close the float terminal after 3 seconds
-- 			vim.defer_fn(function()
-- 				vim.api.nvim_win_close(countdown_win_id, true)
-- 			end, 0)
-- 		end,
-- 	})
-- end
--
-- return M
