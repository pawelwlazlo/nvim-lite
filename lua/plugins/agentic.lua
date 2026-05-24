-- ============================================================================
-- AGENTIC.NVIM - Claude Code (and other ACP agents) in Neovim
-- ============================================================================
-- Requires the ACP bridge binary on PATH:
--   npm i -g @agentclientprotocol/claude-agent-acp
-- Authentication is reused from the `claude` CLI (no API key in nvim).

local agentic = require("agentic")

agentic.setup({
	provider = "claude-agent-acp",
	windows = {
		position = "right",
	},
})

local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

map("n", "<leader>ac", agentic.toggle, "Agentic: toggle chat")
map("n", "<leader>ao", agentic.open, "Agentic: open chat")
map("n", "<leader>aq", agentic.close, "Agentic: close chat")
map("n", "<leader>an", agentic.new_session, "Agentic: new session")
map("n", "<leader>aN", agentic.new_session_with_provider, "Agentic: new session (pick provider)")
map("n", "<leader>ar", agentic.restore_session, "Agentic: restore session")
map("n", "<leader>aS", agentic.switch_provider, "Agentic: switch provider")
map("n", "<leader>ax", agentic.stop_generation, "Agentic: stop generation")
map("n", "<leader>al", agentic.rotate_layout, "Agentic: rotate layout")

-- Context capture
map("n", "<leader>af", agentic.add_file, "Agentic: add current file to context")
map("n", "<leader>ad", agentic.add_current_line_diagnostics, "Agentic: add line diagnostics")
map("n", "<leader>aD", agentic.add_buffer_diagnostics, "Agentic: add buffer diagnostics")
map({ "v", "x" }, "<leader>as", agentic.add_selection, "Agentic: add selection to context")
