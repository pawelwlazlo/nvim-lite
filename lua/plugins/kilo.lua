-- ============================================================================
-- KILO CLI INTEGRATION
-- ============================================================================

local function run_kilo_command(argv)
	if vim.fn.executable("kilo") ~= 1 then
		vim.notify("kilo executable not found in PATH", vim.log.levels.ERROR)
		return
	end

	Snacks.terminal.open(argv, {
		on_exit = function(exit_code)
			if exit_code ~= 0 then
				vim.notify("Kilo command failed with exit code " .. exit_code, vim.log.levels.ERROR)
			end
		end,
	})
end

local function kilo_terminal()
	run_kilo_command({ "kilo" })
end

local function kilo_with_file()
	local file_path = vim.fn.expand("%:p")
	if file_path == "" or file_path:match("^term://") then
		vim.notify("No valid file to send to Kilo", vim.log.levels.WARN)
		return
	end

	run_kilo_command({ "kilo", "run", "--file", file_path, "Review this file and provide actionable recommendations." })
end

local function kilo_with_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local start_line = start_pos[2]
	local start_col = start_pos[3]
	local end_line = end_pos[2]
	local end_col = end_pos[3]

	if start_line == 0 or end_line == 0 then
		vim.notify("No visual selection found", vim.log.levels.WARN)
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	if #lines == 0 then
		vim.notify("No selection to send to Kilo", vim.log.levels.WARN)
		return
	end

	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_col, end_col)
	else
		lines[1] = string.sub(lines[1], start_col)
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end

	local selected_text = table.concat(lines, "\n")
	if selected_text:match("^%s*$") then
		vim.notify("No valid selection to send to Kilo", vim.log.levels.WARN)
		return
	end

	run_kilo_command({ "kilo", "run", "Work on this code selection:\n\n" .. selected_text })
end

vim.keymap.set("n", "<leader>cc", kilo_terminal, { noremap = true, silent = true, desc = "Open Kilo terminal" })
vim.keymap.set("n", "<leader>cf", kilo_with_file, { noremap = true, silent = true, desc = "Run Kilo with current file" })
vim.keymap.set("v", "<leader>cs", kilo_with_selection, { noremap = true, silent = true, desc = "Run Kilo with selection" })
