# snacks.nvim Integration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate snacks.nvim by replacing mini.notify, mini.cursorword, and the custom floating terminal with snacks equivalents, and add nine new features: dashboard, lazygit, bigfile, smooth scroll, zen mode, git browse, UI toggles, statuscolumn, and file rename with LSP update.

**Architecture:** snacks.nvim is registered via `vim.pack.add` + `packadd` in `lua/plugins/init.lua` and configured in a new `lua/plugins/snacks.lua`. `terminal.lua` is deleted. `mini.notify` and `mini.cursorword` are removed from `mini-plugins.lua`. `<leader>td` is removed from `core/keymaps.lua` and replaced by `snacks.toggle`.

**Tech Stack:** Neovim 0.12+, snacks.nvim (folke/snacks.nvim), vim.pack (built-in plugin manager)

---

### Task 1: Register snacks.nvim + stub config

**Files:**
- Modify: `lua/plugins/init.lua`
- Create: `lua/plugins/snacks.lua`

- [ ] **Step 1: Add snacks.nvim to plugin list**

In `lua/plugins/init.lua`, add to the `vim.pack.add({...})` array (after the last entry, before the closing `})`):

```lua
"https://github.com/folke/snacks.nvim",
```

- [ ] **Step 2: Add packadd call**

In `lua/plugins/init.lua`, add after the last `packadd(...)` line (before the `-- PLUGIN CONFIGS` comment):

```lua
packadd("snacks.nvim")
```

- [ ] **Step 3: Create stub snacks.lua**

Create `lua/plugins/snacks.lua` with this content:

```lua
-- ============================================================================
-- SNACKS.NVIM
-- ============================================================================

require("snacks").setup({})
```

- [ ] **Step 4: Load snacks config from init.lua**

In `lua/plugins/init.lua`, at the bottom of the `-- PLUGIN CONFIGS` section, add:

```lua
require("plugins.snacks")
```

- [ ] **Step 5: Verify Neovim starts cleanly**

Run:
```bash
nvim --headless +q 2>&1 | grep -i "error\|E[0-9]\{3\}"
```
Expected: no output (or only unrelated warnings already present before this change).

- [ ] **Step 6: Commit**

```bash
git add lua/plugins/init.lua lua/plugins/snacks.lua
git commit -m "feat: register snacks.nvim with stub config"
```

---

### Task 2: Migrate mini.notify → snacks.notifier, mini.cursorword → snacks.words

**Files:**
- Modify: `lua/plugins/mini-plugins.lua`
- Modify: `lua/plugins/snacks.lua`

- [ ] **Step 1: Remove mini.notify and mini.cursorword from mini-plugins.lua**

In `lua/plugins/mini-plugins.lua`, remove these two lines:

```lua
require("mini.notify").setup({})
require("mini.cursorword").setup({})
```

The file after removal should contain only:

```lua
-- ============================================================================
-- MINI.NVIM PLUGINS CONFIG
-- ============================================================================

require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.icons").setup({})
```

- [ ] **Step 2: Add notifier + words config to snacks.lua**

Replace `lua/plugins/snacks.lua` with:

```lua
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
```

- [ ] **Step 3: Verify startup and notifications**

```bash
nvim --headless +q 2>&1 | grep -i "error\|E[0-9]\{3\}"
```
Expected: no new errors.

Open Neovim manually and run `:lua vim.notify("test", vim.log.levels.INFO)` — should show a fancy toast notification, not mini.nvim style.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/mini-plugins.lua lua/plugins/snacks.lua
git commit -m "feat: migrate mini.notify->snacks.notifier, mini.cursorword->snacks.words"
```

---

### Task 3: Migrate terminal.lua → snacks.terminal

**Files:**
- Modify: `lua/plugins/init.lua` (remove terminal require)
- Modify: `lua/plugins/snacks.lua` (add terminal config + keymaps)
- Delete: `lua/plugins/terminal.lua`

- [ ] **Step 1: Add terminal config to snacks.lua**

In `lua/plugins/snacks.lua`, add `terminal` to the `require("snacks").setup({...})` table and add keymaps after setup. Full file:

```lua
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
```

- [ ] **Step 2: Remove terminal.lua require from init.lua**

In `lua/plugins/init.lua`, remove this line from the `-- PLUGIN CONFIGS` section:

```lua
require("plugins.terminal")
```

- [ ] **Step 3: Delete terminal.lua**

```bash
git rm lua/plugins/terminal.lua
```

- [ ] **Step 4: Verify terminal works**

```bash
nvim --headless +q 2>&1 | grep -i "error\|E[0-9]\{3\}"
```

Open Neovim manually: press `<leader>t` → floating terminal opens. Press `<Esc>` → closes. Press `<leader>t` again → same terminal session reopens (buffer persists).

- [ ] **Step 5: Commit**

```bash
git add lua/plugins/init.lua lua/plugins/snacks.lua
git commit -m "feat: migrate custom terminal.lua to snacks.terminal"
```

---

### Task 4: Add snacks.toggle + remove <leader>td

**Files:**
- Modify: `lua/core/keymaps.lua` (remove `<leader>td`)
- Modify: `lua/plugins/snacks.lua` (add toggle config + keymaps)

- [ ] **Step 1: Remove <leader>td from keymaps.lua**

In `lua/core/keymaps.lua`, remove lines 53-55:

```lua
vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })
```

- [ ] **Step 2: Add toggle to snacks.lua setup and add toggle keymaps**

In `lua/plugins/snacks.lua`, add `toggle = { enabled = true }` to the setup table, and add the toggle keymaps after the existing keymaps. The additions are:

In the `require("snacks").setup({...})` table, add:

```lua
  toggle = { enabled = true },
```

After the existing keymap calls at the bottom, add:

```lua
-- UI toggles
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_numbers():map("<leader>ul")
Snacks.toggle.option("spell", { name = "Spell" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("conceallevel", {
  off = 0,
  on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
  name = "Conceal",
}):map("<leader>uc")
Snacks.toggle.inlay_hints():map("<leader>uh")
```

Full `lua/plugins/snacks.lua` after this task:

```lua
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
  toggle = { enabled = true },
  words = {
    enabled = true,
    debounce = 200,
    notify_jump = false,
    notify_end = false,
  },
})

-- Terminal
vim.keymap.set("n", "<leader>t", function()
  Snacks.terminal.toggle()
end, { noremap = true, silent = true, desc = "Toggle floating terminal" })

vim.keymap.set("t", "<Esc>", function()
  Snacks.terminal.toggle()
end, { noremap = true, silent = true, desc = "Close floating terminal" })

-- Notifications
vim.keymap.set("n", "<leader>n", function()
  Snacks.notifier.show_history()
end, { desc = "Notification history" })

-- UI toggles
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_numbers():map("<leader>ul")
Snacks.toggle.option("spell", { name = "Spell" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("conceallevel", {
  off = 0,
  on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
  name = "Conceal",
}):map("<leader>uc")
Snacks.toggle.inlay_hints():map("<leader>uh")
```

- [ ] **Step 3: Verify**

```bash
nvim --headless +q 2>&1 | grep -i "error\|E[0-9]\{3\}"
```

Open Neovim: press `<leader>ud` → diagnostics toggle (gutter signs should appear/disappear). Press `<leader>us` → spell check on/off.

- [ ] **Step 4: Commit**

```bash
git add lua/core/keymaps.lua lua/plugins/snacks.lua
git commit -m "feat: add snacks.toggle, remove legacy <leader>td diagnostics keymap"
```

---

### Task 5: Add snacks.dashboard

**Files:**
- Modify: `lua/plugins/snacks.lua`

- [ ] **Step 1: Add dashboard config to snacks.lua setup table**

In `lua/plugins/snacks.lua`, add the `dashboard` key to `require("snacks").setup({...})`:

```lua
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
```

- [ ] **Step 2: Verify dashboard appears on startup**

```bash
nvim --headless +q 2>&1 | grep -i "error\|E[0-9]\{3\}"
```

Open Neovim with no arguments: `nvim` — dashboard should appear with the ASCII header, key shortcuts, and recent files list.

Open with a file argument: `nvim README.md` — dashboard should NOT appear (opens file directly).

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/snacks.lua
git commit -m "feat: add snacks.dashboard with fzf-lua action keys"
```

---

### Task 6: Add snacks.lazygit + snacks.gitbrowse

**Files:**
- Modify: `lua/plugins/snacks.lua`

- [ ] **Step 1: Add lazygit + gitbrowse to setup table**

In `lua/plugins/snacks.lua`, add to `require("snacks").setup({...})`:

```lua
  gitbrowse = { enabled = true },
  lazygit = { enabled = true },
```

- [ ] **Step 2: Add keymaps after the toggle section**

In `lua/plugins/snacks.lua`, add after the existing keymaps:

```lua
-- Git
vim.keymap.set("n", "<leader>gg", function()
  Snacks.lazygit()
end, { desc = "LazyGit" })

vim.keymap.set("n", "<leader>gB", function()
  Snacks.gitbrowse()
end, { desc = "Git browse" })
```

- [ ] **Step 3: Verify**

```bash
nvim --headless +q 2>&1 | grep -i "error\|E[0-9]\{3\}"
```

Open Neovim inside the git repo: press `<leader>gg` → LazyGit opens in a floating terminal. Press `q` in LazyGit to close.

Press `<leader>gB` on a line inside a tracked file → browser opens to that line on GitHub/GitLab (requires remote to be set and internet access).

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/snacks.lua
git commit -m "feat: add snacks.lazygit (<leader>gg) and snacks.gitbrowse (<leader>gB)"
```

---

### Task 7: Add snacks.bigfile + snacks.scroll

**Files:**
- Modify: `lua/plugins/snacks.lua`

- [ ] **Step 1: Add bigfile + scroll to setup table**

In `lua/plugins/snacks.lua`, add to `require("snacks").setup({...})`:

```lua
  bigfile = {
    enabled = true,
    size = 1.5 * 1024 * 1024,
  },
  scroll = {
    enabled = true,
    animate = {
      duration = { step = 15, total = 150 },
      easing = "linear",
    },
  },
```

- [ ] **Step 2: Verify**

```bash
nvim --headless +q 2>&1 | grep -i "error\|E[0-9]\{3\}"
```

Open Neovim: press `<C-d>` or `<C-u>` — scrolling should feel smooth (animated). Open a file >1.5MB — syntax highlighting and treesitter should be automatically disabled (check with `:set syntax?` → `nosyntax`).

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/snacks.lua
git commit -m "feat: add snacks.bigfile (1.5MB threshold) and snacks.scroll (smooth)"
```

---

### Task 8: Add snacks.zen + snacks.rename + snacks.statuscolumn

**Files:**
- Modify: `lua/plugins/snacks.lua`

- [ ] **Step 1: Add zen, rename, statuscolumn to setup table**

In `lua/plugins/snacks.lua`, add to `require("snacks").setup({...})`:

```lua
  rename = { enabled = true },
  statuscolumn = { enabled = true },
  zen = {
    enabled = true,
    win = { width = 120 },
    toggles = {
      dim = false,
      git_signs = true,
      diagnostics = false,
      inlay_hints = false,
    },
    show = {
      statusline = false,
      tabline = false,
    },
  },
```

- [ ] **Step 2: Add zen and rename keymaps**

In `lua/plugins/snacks.lua`, add after the git keymaps:

```lua
-- Zen mode
vim.keymap.set("n", "<leader>z", function()
  Snacks.zen()
end, { desc = "Zen mode" })

-- File rename with LSP
vim.keymap.set("n", "<leader>cR", function()
  Snacks.rename.rename_file()
end, { desc = "Rename file" })
```

- [ ] **Step 3: Final state of lua/plugins/snacks.lua**

At this point the file should contain:

```lua
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
  rename      = { enabled = true },
  scroll = {
    enabled = true,
    animate = {
      duration = { step = 15, total = 150 },
      easing = "linear",
    },
  },
  statuscolumn = { enabled = true },
  terminal = {
    enabled = true,
    win = {
      border = "rounded",
      width = 0.8,
      height = 0.8,
      position = "float",
    },
  },
  toggle = { enabled = true },
  words = {
    enabled = true,
    debounce = 200,
    notify_jump = false,
    notify_end = false,
  },
  zen = {
    enabled = true,
    win = { width = 120 },
    toggles = {
      dim = false,
      git_signs = true,
      diagnostics = false,
      inlay_hints = false,
    },
    show = {
      statusline = false,
      tabline = false,
    },
  },
})

-- Terminal
vim.keymap.set("n", "<leader>t", function()
  Snacks.terminal.toggle()
end, { noremap = true, silent = true, desc = "Toggle floating terminal" })

vim.keymap.set("t", "<Esc>", function()
  Snacks.terminal.toggle()
end, { noremap = true, silent = true, desc = "Close floating terminal" })

-- Notifications
vim.keymap.set("n", "<leader>n", function()
  Snacks.notifier.show_history()
end, { desc = "Notification history" })

-- UI toggles
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_numbers():map("<leader>ul")
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

-- Zen mode
vim.keymap.set("n", "<leader>z", function()
  Snacks.zen()
end, { desc = "Zen mode" })

-- File rename with LSP
vim.keymap.set("n", "<leader>cR", function()
  Snacks.rename.rename_file()
end, { desc = "Rename file" })
```

- [ ] **Step 4: Verify**

```bash
nvim --headless +q 2>&1 | grep -i "error\|E[0-9]\{3\}"
```

Open Neovim: press `<leader>z` → screen narrows to 120 cols, statusline disappears, git signs remain. Press `<leader>z` again → exits zen. Open a tracked file, press `<leader>cR` → prompt for new filename; after rename, LSP is notified.

- [ ] **Step 5: Commit**

```bash
git add lua/plugins/snacks.lua
git commit -m "feat: add snacks.zen, snacks.rename, snacks.statuscolumn"
```

---

### Task 9: Write SNACKS.md tutorial

**Files:**
- Create: `SNACKS.md`

- [ ] **Step 1: Create the tutorial**

Create `SNACKS.md` at the repo root with:

```markdown
# snacks.nvim — Practical Guide

`snacks.nvim` (by folke) is a collection of small but polished Neovim utilities. This config uses 12 of its modules. Each section below shows what it does and how to use it.

---

## Notifications

snacks.notifier replaces the default `vim.notify` with animated toast notifications.

**Usage from Lua:**
```lua
vim.notify("message")                           -- info (default)
vim.notify("something failed", vim.log.levels.ERROR)
vim.notify("heads up", vim.log.levels.WARN)
Snacks.notify.info("hello")                     -- shorthand
Snacks.notify.error("something broke")
```

| Key | Action |
|---|---|
| `<leader>n` | Show notification history |

**Tip:** Notifications auto-dismiss after 3 seconds. History keeps the last ~50.

---

## Terminal

snacks.terminal manages a persistent floating terminal — the same shell session survives open/close cycles.

| Key | Action |
|---|---|
| `<leader>t` (normal mode) | Open / close terminal |
| `<Esc>` (terminal mode) | Close terminal |

**Tip:** The terminal buffer is hidden (not deleted) on close, so your shell history and working directory persist.

---

## LazyGit

Opens [LazyGit](https://github.com/jesseduffield/lazygit) in a snacks floating window. Requires `lazygit` to be installed (`brew install lazygit`).

| Key | Action |
|---|---|
| `<leader>gg` | Open LazyGit |

**Typical workflow:** `<leader>gg` → stage hunks with `<Space>` → commit with `c` → push with `P` → `q` to close.

**Tip:** LazyGit has its own help page accessible with `?` from any view.

---

## Dashboard

Appears when Neovim is opened with no file arguments. Shows a header, quick-action keys, and recent files.

**Quick-action keys (shown in dashboard):**

| Key | Action |
|---|---|
| `f` | Find file (fzf-lua) |
| `r` | Recent files (fzf-lua) |
| `g` | Live grep (fzf-lua) |
| `L` | Open LazyGit |
| `q` | Quit Neovim |

**Tip:** Opening Neovim with a file (`nvim myfile.lua`) skips the dashboard entirely.

---

## Zen Mode

Hides distractions: statusline, tabline, line numbers outside the focused window. Sets a fixed width of 120 columns.

| Key | Action |
|---|---|
| `<leader>z` | Toggle zen mode |

**Tip:** Git signs remain visible in zen mode so you can still track changes. Use it for writing prose or focused code review.

---

## UI Toggles

`snacks.toggle` provides standardised on/off switches with which-key labels and status feedback in notifications.

| Key | Toggle |
|---|---|
| `<leader>ud` | Diagnostics (virtual text + signs) |
| `<leader>ul` | Line numbers |
| `<leader>us` | Spell check |
| `<leader>uw` | Word wrap |
| `<leader>uc` | Conceal level (0 ↔ 2) |
| `<leader>uh` | Inlay hints (LSP) |

**Tip:** Each toggle shows a notification when switched (e.g. "Diagnostics: enabled"). Current state is preserved per buffer where applicable.

---

## Git Browse

Opens the current file (or visual selection) in your browser at the correct line on GitHub, GitLab, or Gitea. Requires the buffer to be in a git repo with a remote set.

| Key | Action |
|---|---|
| `<leader>gB` | Open current line in browser |
| `<leader>gB` (visual) | Open selected range in browser |

**Tip:** Works with GitHub, GitLab, Gitea, and Bitbucket. The URL resolves to the current commit SHA for a stable link.

---

## Bigfile

Automatically detects files larger than **1.5 MB** and disables expensive features to keep Neovim responsive.

**What gets disabled automatically:**
- Treesitter highlighting
- LSP attachment
- Vim syntax highlighting
- Sign column features

No action required — it's fully automatic.

**Tip:** The threshold is 1.5 MB. If you regularly work with large generated files (logs, minified JS), you can lower it in `lua/plugins/snacks.lua` → `bigfile.size`.

---

## Statuscolumn

Replaces Neovim's default left gutter with a structured layout: fold indicators, git diff signs, and diagnostic icons — in that order, left to right.

Automatic — no keybinding needed.

**Gutter guide:**

| Symbol | Meaning |
|---|---|
| `▶` / `▼` | Fold closed / open |
| `│` | Unchanged line (git) |
| `+` (green) | Added line |
| `~` (yellow) | Changed line |
| `-` (red) | Deleted line below |
| `E` (red) | Error diagnostic |
| `W` (yellow) | Warning diagnostic |
| `I` (blue) | Info diagnostic |
| `H` (cyan) | Hint diagnostic |

---

## File Rename

Renames the current buffer's file on disk and notifies any attached LSP servers so import paths are updated automatically.

| Key | Action |
|---|---|
| `<leader>cR` | Rename current file |

**Tip:** This is different from `<leader>jr` (rename symbol/variable). `<leader>cR` renames the file itself; `<leader>jr` renames a symbol in the code.

---

## Scroll

Adds smooth animated scrolling for `<C-d>`, `<C-u>`, `<C-f>`, `<C-b>`, `gg`, `G`, and search jumps.

Automatic — no keybinding needed.

**Config** (in `lua/plugins/snacks.lua` → `scroll.animate`):
- `total`: animation duration in ms (default: 150)
- `easing`: `"linear"` keeps constant speed; `"outCubic"` decelerates at the end

**Tip:** If smooth scroll feels slow when jumping large distances, reduce `total` to `80`–`100`.
```

- [ ] **Step 2: Verify the file**

```bash
wc -l SNACKS.md
```
Expected: ~160 lines.

- [ ] **Step 3: Commit**

```bash
git add SNACKS.md
git commit -m "docs: add SNACKS.md practical guide for snacks.nvim modules"
```

---

### Task 10: Update KEYBINDINGS.md + commit spec/plan

**Files:**
- Modify: `KEYBINDINGS.md`

- [ ] **Step 1: Read current KEYBINDINGS.md to find insertion points**

Open `KEYBINDINGS.md` and locate:
- A `Git` or `<leader>g` section → add `<leader>gg` and `<leader>gB`
- A `Terminal` section → update `<leader>t` description
- A `UI` or miscellaneous section → add `<leader>ud/ul/us/uw/uc/uh`
- A `Code` or `<leader>c` section → add `<leader>cR`
- Add `<leader>z` (zen), `<leader>n` (notifications) where appropriate

- [ ] **Step 2: Add new snacks keybindings**

Add these entries in the appropriate sections of `KEYBINDINGS.md`:

```markdown
### Git (snacks)
| `<leader>gg` | Open LazyGit |
| `<leader>gB` | Git browse — open current line in browser |

### Terminal (snacks)
| `<leader>t` | Toggle floating terminal |

### UI Toggles (snacks)
| `<leader>ud` | Toggle diagnostics |
| `<leader>ul` | Toggle line numbers |
| `<leader>us` | Toggle spell check |
| `<leader>uw` | Toggle word wrap |
| `<leader>uc` | Toggle conceal level |
| `<leader>uh` | Toggle inlay hints |

### Zen / Focus
| `<leader>z` | Toggle zen mode |

### Notifications
| `<leader>n` | Show notification history |

### Code / File
| `<leader>cR` | Rename file (+ LSP import update) |
```

- [ ] **Step 3: Commit KEYBINDINGS.md and design doc**

```bash
git add KEYBINDINGS.md docs/superpowers/specs/2026-05-03-snacks-nvim-design.md docs/superpowers/plans/2026-05-03-snacks-nvim.md
git commit -m "docs: update KEYBINDINGS.md with snacks keybindings, add spec and plan"
```

---

## Spec Coverage Check

| Spec requirement | Task |
|---|---|
| Register snacks.nvim via vim.pack | Task 1 |
| mini.notify → snacks.notifier | Task 2 |
| mini.cursorword → snacks.words | Task 2 |
| terminal.lua → snacks.terminal | Task 3 |
| snacks.toggle + remove `<leader>td` | Task 4 |
| snacks.dashboard | Task 5 |
| snacks.lazygit (`<leader>gg`) | Task 6 |
| snacks.gitbrowse (`<leader>gB`) | Task 6 |
| snacks.bigfile (1.5MB) | Task 7 |
| snacks.scroll (150ms linear) | Task 7 |
| snacks.zen (`<leader>z`, width 120) | Task 8 |
| snacks.rename (`<leader>cR`) | Task 8 |
| snacks.statuscolumn | Task 8 |
| SNACKS.md tutorial | Task 9 |
| KEYBINDINGS.md update | Task 10 |
