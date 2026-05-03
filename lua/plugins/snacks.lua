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
  words = {
    enabled = true,
    debounce = 200,
    notify_jump = false,
    notify_end = false,
  },
})

vim.keymap.set("n", "<leader>n", function()
  Snacks.notifier.show_history()
end, { desc = "Notification history" })
