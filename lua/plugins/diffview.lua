local M = {}

local configured = false

function M.setup()
	if configured then
		return
	end
	configured = true
	require("diffview").setup({
		enhanced_diff_hl = true,
	})
end

function M.open()
	M.setup()
	vim.cmd("DiffviewOpen")
end

vim.keymap.set("n", "<leader>gv", M.open, { desc = "Diffview (changes)" })

return M
