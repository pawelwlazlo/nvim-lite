-- ============================================================================
-- SNACKS.NVIM
-- ============================================================================

require("snacks").setup({
  notifier = {
    enabled = true,
    style = "fancy",
    timeout = 3000,
    icons = {
      error = " ",
      warn = " ",
      info = " ",
      debug = " ",
      trace = "✎",
    },
  },
  terminal = {
    enabled = true,
    win = {
      border = "rounded",
      width = 0.8,
      height = 0.8,
      position = "float",
    },
  },
  words = {
    enabled = true,
    debounce = 200,
    notify_jump = false,
    notify_end = false,
  },
})

vim.keymap.set("n", "<leader>t", function()
  Snacks.terminal.toggle()
end, { noremap = true, silent = true, desc = "Toggle floating terminal" })

vim.keymap.set("t", "<Esc>", function()
  Snacks.terminal.toggle()
end, { noremap = true, silent = true, desc = "Close floating terminal" })

vim.keymap.set("n", "<leader>n", function()
  Snacks.notifier.show_history()
end, { desc = "Notification history" })
