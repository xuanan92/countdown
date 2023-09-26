local M = {}
local countdown_job_id
local countdown_win_id

function M.setup()
	-- Setup code for the plugin (if needed)
	-- vim.cmd("command! -nargs=1 Countdown lua require('countdown').countdown(<args>)")
end

function M.sound()
	-- linux
	os.execute("timeout 1 aplay $HOME/mydotfile/joplin/sounds/pr_in_space.mp3")
end

function M.countdown(minus)
	local duration = tonumber(minus) * 60
	if countdown_job_id then
		-- If a countdown is already running, stop the current countdown
		vim.fn.jobstop(countdown_job_id)
		vim.api.nvim_win_close(countdown_win_id, true)
		countdown_job_id = nil
	end

	local width = 50
	local height = 2
	--
	-- Get the current buffer and window
	local current_buffer = vim.api.nvim_get_current_buf()
	local current_window = vim.api.nvim_get_current_win()

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
			[[for i in $(seq %d -1 1); do echo "You set work duration for %d minutes \n Countdown: $i seconds remaining"; sleep 0.3; done; echo 'Countdown: Time is up!']],
			duration,
			minus
		),
	}, {
		on_stdout = function(_, data)
			vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, data)
		end,
		on_exit = function(_, _)
			countdown_job_id = nil
			vim.cmd("echo 'Countdown: Time is up!'")

			-- Set the current buffer as modifiable
			vim.api.nvim_buf_set_option(current_buffer, "modifiable", true)

			-- Append spent duration on the first line of the current editor
			local addDurationToMin = math.ceil(duration / 60)
			local current_lines = vim.api.nvim_buf_get_lines(current_buffer, 0, 1, false)
			local duration_line = current_lines[1] or ""
			local duration_spent = string.match(duration_line, "#([%d]+)#")
			local durationS_spent = string.match(duration_line, "&([%d]+)&")
			local new_duration
			local new_durationS
			local duration_spent_number = tonumber(duration_spent) or 0
			local durationS_spent_number = tonumber(durationS_spent) or 0
			new_duration = duration_spent_number + addDurationToMin
			new_durationS = durationS_spent_number + addDurationToMin
			duration_line =
				string.gsub(duration_line, "&[%d]+& #[%d]+#", "&" .. new_durationS .. "& #" .. new_duration .. "#")

			vim.api.nvim_buf_set_lines(current_buffer, 0, 1, false, { duration_line })

			-- Append "&0& " to the next line after the line containing "# =Plans="
			local current_Nlines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)
			local plans_line_number
			for i, line in ipairs(current_Nlines) do
				if line:find("# =Plans=") then
					plans_line_number = i
					break
				end
			end

			if plans_line_number then
				local next_line_number = plans_line_number + 1
				local next_line = current_Nlines[next_line_number]
				if next_line then
					local duration_action = string.match(next_line, "&([%d]+)&")
					if duration_action then
						next_line = string.gsub(next_line, "&[%d]+&", "&" .. new_durationS .. "&")
					else
						next_line = "&" .. new_durationS .. "& " .. next_line
					end
					vim.api.nvim_buf_set_lines(
						current_buffer,
						plans_line_number,
						next_line_number,
						false,
						{ next_line }
					)
				end
			end
			-- Play the sound
			M.sound()

			-- Close the float terminal after 0 seconds
			vim.defer_fn(function()
				vim.api.nvim_win_close(countdown_win_id, true)
				vim.api.nvim_set_current_win(current_window)
			end, 0)
		end,
	})
end

function M.countreset()
	local history_line_number
	local current_buffer = vim.api.nvim_get_current_buf()
	local first_line = vim.api.nvim_buf_get_lines(current_buffer, 0, 1, false)
	first_line[1] = string.gsub(first_line[1], "&[%d]+&", "&0&")
	vim.api.nvim_buf_set_lines(current_buffer, 0, 1, false, { first_line[1] })

	-- Append "&0& " to the next line after the line containing "# =Plans="
	local current_Nlines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)
	local plans_line_number
	for i, line in ipairs(current_Nlines) do
		if line:find("# =Plans=") then
			plans_line_number = i
			break
		end
	end
	local new_line = current_Nlines[plans_line_number + 1]
	table.remove(current_Nlines, plans_line_number + 1)
	vim.api.nvim_buf_set_lines(current_buffer, 0, -1, false, { unpack(current_Nlines) })
	-- append new lines to history next line
	for i, line in ipairs(current_Nlines) do
		if line:find("# =History=") then
			history_line_number = i
			break
		end
	end
	if history_line_number then
		local next_line_number = history_line_number + 1
		local next_line = current_Nlines[next_line_number]
		if next_line then
			table.insert(current_Nlines, next_line_number, new_line)
			vim.api.nvim_buf_set_lines(current_buffer, 0, -1, false, { unpack(current_Nlines) })
		end
	end
end

function M.countadd(minus)
	-- add time here with a number
	-- when command Countadd 15 it will
	-- find all three places
	local number = tonumber(minus) * 60
	local current_buffer = vim.api.nvim_get_current_buf()
	-- find the first line
	local first_line = vim.api.nvim_buf_get_lines(current_buffer, 0, 1, false)
	local action_initNumber = string.match(first_line[1], "&([%d]+)&")
	local project_initNumber = string.match(first_line[1], "#([%d]+)#")
	first_line[1] = string.gsub(
		first_line[1],
		"&[%d]+& #[%d]+#",
		"&"
			.. (tonumber(action_initNumber) + tonumber(number))
			.. "& #"
			.. (tonumber(project_initNumber) + tonumber(number))
			.. "#"
	)
	-- update
	vim.api.nvim_buf_set_lines(current_buffer, 0, 1, false, { first_line[1] })
	-- find the line after plan
	local current_Nlines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)
	local plans_line_number
	for i, line in ipairs(current_Nlines) do
		if line:find("# =Plans=") then
			plans_line_number = i
			break
		end
	end
	-- update
	if plans_line_number then
		local next_line_number = plans_line_number + 1
		local next_line = current_Nlines[next_line_number]
		if next_line then
			local duration_action = string.match(next_line, "&([%d]+)&")
			if duration_action then
				next_line =
					string.gsub(next_line, "&[%d]+&", "&" .. (tonumber(action_initNumber) + tonumber(number)) .. "&")
			else
				next_line = "&" .. (tonumber(action_initNumber) + tonumber(number)) .. "& " .. next_line
			end
			vim.api.nvim_buf_set_lines(current_buffer, plans_line_number, next_line_number, false, { next_line })
		end
	end
end

return M
