function M.countdown(hours, minutes)
	if countdown_job_id then
		print("Countdown is already running. Please wait for the current countdown to finish.")
		return
	end

	local total_seconds = hours * 3600 + minutes * 60
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
			[[for ((s=%d; s>=0; s--)); do
          h=$((s/3600)); m=$((s/60%60)); s=$((s%60))
          printf "Countdown: %02d:%02d:%02d remaining\n" $h $m $s
          sleep 1
      done
      echo 'Countdown: Time is up!']],
			total_seconds
		),
	}, {
		on_stdout = function(_, data)
			vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, data)
		end,
		on_exit = function()
			countdown_job_id = nil
			vim.cmd("echo 'Countdown: Time is up!'")
			vim.api.nvim_buf_set_option(buf_id, "modifiable", false)
		end,
	})
end
