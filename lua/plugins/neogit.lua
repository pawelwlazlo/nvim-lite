local M = {}

local configured = false

function M.setup()
	if configured then
		return
	end
	configured = true
	require("plugins.diffview").setup()
	require("neogit").setup({
		integrations = {
			diffview = true,
		},
	})
end

function M.open()
	M.setup()
	require("neogit").open()
end

vim.keymap.set("n", "<leader>gc", M.open, { desc = "Neogit (commit)" })

return M
