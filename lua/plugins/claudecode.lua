
require("claudecode").setup({
	auto_start = true,
	terminal = {
		provider = "snacks",
		split_side = "right",
		split_width_percentage = 0.35,
		snacks_win_opts = {
			keys = { term_normal = false },
		},
	},
})

local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

map("n", "<leader>ac", "<cmd>ClaudeCode<cr>", "Toggle Claude Code")
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", "Focus Claude Code")
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", "Resume Claude session")
map("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", "Continue last Claude session")
map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", "Select Claude model")
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", "Add current buffer to Claude")
map("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", "Send selection to Claude")
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", "Accept Claude diff")
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", "Deny Claude diff")

vim.api.nvim_create_autocmd("FileType", {
	pattern = "NvimTree",
	callback = function(event)
		vim.keymap.set("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", {
			buffer = event.buf,
			noremap = true,
			silent = true,
			desc = "Add file under cursor to Claude",
		})
	end,
})
