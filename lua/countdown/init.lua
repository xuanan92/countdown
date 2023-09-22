local M = {}
local countdown_job_id
local countdown_win_id

function M.setup()
	-- Setup code for the plugin (if needed)
	-- vim.cmd("command! -nargs=1 Countdown lua require('countdown').countdown(<args>)")
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
			vim.api.nvim_buf_set_option(buf_id, "modifiable", true)
			-- Append spent duration on the first line of the current editor
			local duration_line = vim.api.nvim_buf_get_lines(current_buffer, 0, 1, false)[1] or ""
			local duration_spent = string.match(duration_line, "#durationspent#%s+(%d+)")
			local new_duration

			if duration_spent then
				new_duration = tonumber(duration_spent) + duration
				duration_line = string.gsub(duration_line, "#durationspent#%s+%d+", "#durationspent# " .. new_duration)
			else
				duration_line = "#durationspent# " .. duration
			end

			vim.api.nvim_buf_set_lines(current_buffer, 0, 1, false, { duration_line })

			-- Set the current buffer as non-modifiable again
			vim.api.nvim_buf_set_option(current_buffer, "modifiable", false)
			-- Close the float terminal after 0 seconds
			vim.defer_fn(function()
				vim.api.nvim_win_close(countdown_win_id, true)
			end, 0)
		end,
	})
end

return M
