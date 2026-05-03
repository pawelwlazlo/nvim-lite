# Snacks.nvim Guide

**Snacks.nvim** is a utility library for Neovim providing a collection of small, fast plugins. This config uses 12 snacks modules to extend editor functionality: notifications, terminal, lazygit, dashboard, zen mode, UI toggles, git browse, bigfile, statuscolumn, rename, scroll, and word highlight.

## Notifications

**Show notification history and send custom notifications via `Snacks.notify.*` API.**

| Action | Keybinding |
|--------|-----------|
| Show notification history | `<leader>n` |

Use `Snacks.notify()` in Lua for info messages, `Snacks.notify.warn()` for warnings, and `Snacks.notify.error()` for errors. Each notification auto-dismisses after 3 seconds.

**Tip:** Notifications persist in history across sessions; check `<leader>n` to review past messages.

## Terminal

**Floating terminal overlay for running shell commands without leaving the editor.**

| Action | Keybinding |
|--------|-----------|
| Open/close terminal | `<leader>t` |
| Close terminal (terminal mode) | `<Esc>` |

Terminal window is 80% width and 80% height, centered, with rounded borders. Press `<Esc>` in terminal mode to hide; use `<leader>t` to toggle back to the same terminal session.

**Tip:** Terminal buffer persists across toggles—navigate back to the same working directory and history each time you reopen.

## LazyGit

**Git UI integration with lazygit. Requires `lazygit` binary installed.**

| Action | Keybinding |
|--------|-----------|
| Open LazyGit | `<leader>gg` |
| LazyGit (Dashboard) | `L` key |

LazyGit opens in a floating window, allowing you to stage, commit, amend, and manage branches without leaving Neovim.

**Tip:** Typical workflow: `<leader>gg` → navigate files → `space` to stage → `c` to commit → `P` to push. Type `?` inside LazyGit to see all keybindings.

## Dashboard

**Welcome screen on `nvim` with no arguments. Quick-action shortcuts and recent file list.**

| Key | Action |
|-----|--------|
| `f` | Find File (FzfLua) |
| `r` | Recent Files (FzfLua oldfiles) |
| `g` | Find Text (FzfLua live_grep) |
| `L` | LazyGit |
| `q` | Quit |

Dashboard displays the Neograin ASCII header, quick-action keys, 8 recent files, and startup time. Opening any file closes the dashboard.

**Tip:** Dashboard appears automatically when launching `nvim` without a file. Use `L` key to jump directly to LazyGit from the dashboard.

## Zen Mode

**Distraction-free writing and coding view. Narrows the editor and hides UI elements.**

| Action | Keybinding |
|--------|-----------|
| Toggle Zen Mode | `<leader>z` |

Zen Mode sets window width to 120 columns and hides the statusline and tabline. It keeps git signs visible so you can still see line changes. Diagnostics and inlay hints are hidden; toggle them back with `<leader>ud` and `<leader>uh` if needed.

**Tip:** Use `<leader>z` to focus on a single file while working on complex logic. Exit with `<leader>z` again to restore full editor width and UI.

## UI Toggles

**Quick toggles for common editor features. Use `<leader>u*` prefix.**

| Toggle | Keybinding | Purpose |
|--------|-----------|---------|
| Diagnostics | `<leader>ud` | Show/hide LSP diagnostics |
| Line Numbers | `<leader>ul` | Show/hide line numbers |
| Spell Check | `<leader>us` | Enable/disable spell checking |
| Word Wrap | `<leader>uw` | Enable/disable line wrapping |
| Conceal | `<leader>uc` | Toggle concealing (0 or level 2) |
| Inlay Hints | `<leader>uh` | Show/hide LSP inlay hints |

Each toggle has a status indicator in the which-key popup. Toggles persist across sessions for some options.

**Tip:** Spell check is language-aware; use `:set spelllang=en_us` to change dictionaries.

## Git Browse

**Open the current file or selection in your Git remote repository (GitHub, GitLab, etc.).**

| Action | Keybinding |
|--------|-----------|
| Open file in Git remote (normal mode) | `<leader>gB` |
| Open selection in Git remote (visual mode) | `<leader>gB` |

Git Browse auto-detects your remote URL and opens it in your default browser. Works with visual selections to link directly to a specific line range.

**Tip:** Supported platforms include GitHub, GitLab, Gitea, and Gitbucket. Uses your Git remote `origin` by default.

## Bigfile

**Automatic performance optimization for large files. Triggered when file size exceeds 1.5 MB.**

When bigfile is triggered, the following features are disabled:
- Syntax highlighting (treesitter)
- LSP
- Formatting
- Search highlighting

You can manually change the threshold in `lua/plugins/snacks.lua` by editing `size = 1.5 * 1024 * 1024` (currently 1.5 MB). Bigfile runs silently in the background—no notification or keypress required.

**Tip:** Bigfile keeps large log files, exports, and data files responsive. Disable with `Snacks.bigfile.disable()` if needed.

## Statuscolumn

**Git signs, diagnostic indicators, and fold markers in the left gutter.**

| Symbol | Meaning |
|--------|---------|
| `▌` | Git added line |
| `▐` | Git modified line |
| `▄` | Git removed line |
| `●` | Diagnostic error |
| `◐` | Diagnostic warning |
| `◦` | Diagnostic info/hint |
| `⋮` | Fold marker |

The statuscolumn runs automatically—no keybinding needed. It combines git signs (from `gitsigns.nvim`) with diagnostics and fold guides for IDE-like visual feedback.

**Tip:** Hover over diagnostic symbols to see the error or warning message. Folded regions show `...` and line count.

## File Rename

**Rename files with LSP symbol rename fallback. Smarter than editing the filename directly.**

| Action | Keybinding |
|--------|-----------|
| Rename file | `<leader>cR` |

File Rename asks for a new filename, then renames the file on disk, updates its buffer, and re-attaches LSP. This differs from `<leader>jr` (LSP symbol rename), which only renames the symbol in code, not the file itself.

**Tip:** Use `<leader>cR` for file operations; use `<leader>jr` to rename a variable, function, or class across the codebase.

## Scroll

**Smooth scrolling with configurable animation. Runs automatically.**

Scroll is enabled by default with smooth animation using `linear` easing, stepping 15ms at a time over a total duration of 150ms. This creates a natural, non-jarring scroll experience when using `<C-u>`, `<C-d>`, and `Page Up`/`Page Down`.

To adjust scroll speed, edit `lua/plugins/snacks.lua`:
```lua
scroll = {
  enabled = true,
  animate = {
    duration = { step = 15, total = 150 },  -- Increase total for slower scroll
    easing = "linear",
  },
}
```

**Tip:** Increase `total` from 150 to 250 for slower, more cinematic scrolling; decrease to 75 for faster scrolling.
