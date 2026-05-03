-- ============================================================================
-- SNACKS.NVIM
-- ============================================================================

require("snacks").setup({
  bigfile = {
    enabled = true,
    size = 1.5 * 1024 * 1024,
  },
  dashboard = {
    enabled = true,
    preset = {
      header = [[
 ███╗   ██╗███████╗ ██████╗ ██████╗ ██████╗  █████╗ ██╗███╗   ██╗███████╗
 ████╗  ██║██╔════╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝
 ██╔██╗ ██║█████╗  ██║   ██║██████╔╝██████╔╝███████║██║██╔██╗ ██║███████╗
 ██║╚██╗██║██╔══╝  ██║   ██║██╔══██╗██╔══██╗██╔══██║██║██║╚██╗██║╚════██║
 ██║ ╚████║███████╗╚██████╔╝██████╔╝██║  ██║██║  ██║██║██║ ╚████║███████║
 ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝]],
      keys = {
        { icon = " ", key = "f", desc = "Find File",    action = ":FzfLua files" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
        { icon = " ", key = "g", desc = "Find Text",    action = ":FzfLua live_grep" },
        { icon = "󰒲 ", key = "L", desc = "LazyGit",      action = function() Snacks.lazygit() end },
        { icon = " ", key = "q", desc = "Quit",         action = ":qa" },
      },
    },
    sections = {
      { section = "header" },
      { section = "keys",         gap = 1, padding = 1 },
      { section = "recent_files", limit = 8, padding = 1 },
      { section = "startup" },
    },
  },
  gitbrowse = { enabled = true },
  lazygit   = { enabled = true },
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
  scroll = {
    enabled = true,
    animate = {
      duration = { step = 15, total = 150 },
      easing = "linear",
    },
  },
  terminal = {
    enabled = true,
    win = {
      border = "rounded",
      width = 0.8,
      height = 0.8,
      position = "float",
      keys = {
        term_normal = {
          "<Esc>",
          function(self) self:hide() end,
          mode = "t",
          desc = "Close terminal",
        },
      },
    },
  },
  toggle = {
    enabled = true,
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

vim.keymap.set("n", "<leader>n", function()
  Snacks.notifier.show_history()
end, { desc = "Notification history" })

-- UI toggles
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.option("spell", { name = "Spell" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("conceallevel", {
  off = 0,
  on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
  name = "Conceal",
}):map("<leader>uc")
Snacks.toggle.inlay_hints():map("<leader>uh")

-- Git
vim.keymap.set("n", "<leader>gg", function()
  Snacks.lazygit()
end, { desc = "LazyGit" })

vim.keymap.set("n", "<leader>gB", function()
  Snacks.gitbrowse()
end, { desc = "Git browse" })
