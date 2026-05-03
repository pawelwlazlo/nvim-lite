# snacks.nvim Integration — Design Spec

**Date:** 2026-05-03  
**Issue:** NER-111  
**Status:** Approved

## Overview

Add `snacks.nvim` (folke) to the Neobrains nvim config using a selective migration + additive approach: replace three existing solutions with superior snacks equivalents, add nine new features, and ship a practical tutorial.

## Approach

Selective migration + additive. Keep `fzf-lua` (battle-tested, well-configured — snacks.picker not worth the migration risk). Replace components where snacks is clearly better. Add modules for features not yet present.

## Architecture

### Plugin Registration

`snacks.nvim` is added to `lua/plugins/init.lua` via `vim.pack.add` + `packadd`, following the existing pattern. All snacks modules are configured in a single new file: `lua/plugins/snacks.lua` using `require("snacks").setup({...})`.

### Removals

| Removed | Replaced by |
|---|---|
| `lua/plugins/terminal.lua` (entire file) | `snacks.terminal` |
| `mini.notify` setup in `mini-plugins.lua` | `snacks.notifier` |
| `mini.cursorword` setup in `mini-plugins.lua` | `snacks.words` |

The `require("plugins.terminal")` call in `plugins/init.lua` is removed. `snacks.terminal` exposes the same `<leader>t` keybinding.

## Modules

### Migration modules (replacing existing)

| Module | Configuration |
|---|---|
| `notifier` | `style = "fancy"`, timeout 3000ms, icons for warn/error/info/debug |
| `terminal` | replaces `<leader>t`, border `"rounded"`, 80%×80% size, `<Esc>` to close |
| `words` | highlight on `CursorHold`, disabled in terminal buffers |

### New modules (additive)

| Module | Keybinding | Description |
|---|---|---|
| `dashboard` | on startup | ASCII header, recent files, find file, quit |
| `lazygit` | `<leader>gg` | LazyGit in floating terminal |
| `bigfile` | automatic | disables treesitter/LSP/syntax for files >1.5MB |
| `scroll` | automatic | smooth scrolling, `easing = "linear"`, 150ms |
| `zen` | `<leader>z` | focus mode, width 120, hides statusline/numbers/signcolumn |
| `gitbrowse` | `<leader>gB` | open current line/selection in browser (GitHub/GitLab/Gitea) |
| `toggle` | `<leader>u*` | standardised toggles (see Keybindings) |
| `statuscolumn` | automatic | folds + git signs + diagnostic icons in gutter |
| `rename` | `<leader>cR` | rename file + LSP import update |

## Keybindings

### New bindings added by snacks

| Key | Action |
|---|---|
| `<leader>gg` | LazyGit |
| `<leader>gB` | Git browse (open in browser) |
| `<leader>z` | Zen mode toggle |
| `<leader>cR` | Rename file (+ LSP) |
| `<leader>n` | Notification history |
| `<leader>us` | Toggle spell check |
| `<leader>uw` | Toggle word wrap |
| `<leader>ul` | Toggle line numbers |
| `<leader>ud` | Toggle diagnostics (replaces `<leader>td`) |
| `<leader>uc` | Toggle conceallevel |
| `<leader>uh` | Toggle inlay hints |

### Modified bindings

`<leader>td` (toggle diagnostics) is superseded by `<leader>ud` from `snacks.toggle`. The old keymap in `core/keymaps.lua` is removed to avoid conflict.

## Tutorial

File: `SNACKS.md` at repo root.

**Structure:**
1. What is snacks.nvim (2-3 sentences)
2. Notifications — `Snacks.notify.*` API, history with `<leader>n`
3. Terminal — `<leader>t`, `<Esc>` to close, persistence
4. LazyGit — `<leader>gg`, typical workflow
5. Dashboard — sections, how to customise
6. Zen Mode — `<leader>z`, use cases
7. Toggle — full table of `<leader>u*` switches
8. Git Browse — `<leader>gB`, supported platforms
9. Bigfile — automatic, no action required
10. Statuscolumn — gutter icons guide
11. Rename — `<leader>cR`, LSP integration
12. Scroll — automatic, smooth scrolling

Each section: one-sentence description + keybinding/example + optional tip.

## What is NOT changed

- `fzf-lua` — kept as-is
- `mini.indentscope` — comparable quality, not worth migrating
- `mini.ai`, `mini.comment`, `mini.move`, `mini.surround`, `mini.pairs`, `mini.trailspace`, `mini.bufremove`, `mini.icons` — all kept

## File Changeset

| File | Change |
|---|---|
| `lua/plugins/init.lua` | Add snacks to `vim.pack.add` + `packadd`; remove `terminal.lua` require |
| `lua/plugins/mini-plugins.lua` | Remove `mini.notify` and `mini.cursorword` setup lines |
| `lua/plugins/terminal.lua` | Delete |
| `lua/plugins/snacks.lua` | Create (new) |
| `lua/core/keymaps.lua` | Remove `<leader>td` diagnostics toggle |
| `SNACKS.md` | Create (new tutorial) |
| `KEYBINDINGS.md` | Update with new snacks keybindings |
