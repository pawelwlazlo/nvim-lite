-- ============================================================================
-- NVIM-TREE CONFIG
-- ============================================================================

require("nvim-tree").setup({
	view = {
		width = 35,
	},
	filters = {
		dotfiles = false,
	},
	actions = {
		open_file = {
			window_picker = {
				exclude = {
					buftype = { "terminal", "help", "quickfix", "prompt" },
					filetype = {
						"notify",
						"qf",
						"diff",
						"fugitive",
						"fugitiveblame",
						"dapui_scopes",
						"dapui_breakpoints",
						"dapui_stacks",
						"dapui_watches",
						"dapui_console",
						"dapui_hover",
						"dap-repl",
						"neotest-summary",
						"neotest-output-panel",
						"aerial",
						"aerial-nav",
						"trouble",
						"OverseerList",
						"OverseerOutput",
						"OverseerForm",
						"DiffviewFiles",
						"DiffviewFileHistory",
						"NeogitStatus",
						"NeogitPopup",
						"gitcommit",
					},
				},
			},
		},
	},
	renderer = {
		group_empty = true,
		icons = {
			glyphs = {
				folder = {
					default = "󰉋",
					open = "󰝰",
					empty = "󰉖",
					empty_open = "󰷏",
					symlink = "󱉆",
					symlink_open = "󱞊",
					arrow_closed = "",
					arrow_open = "",
				},
			},
		},
	},
})
vim.keymap.set("n", "<leader>e", function()
	require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle NvimTree" })

vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
