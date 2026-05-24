# NER-116: Popular Icon Set Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make file-type icons render in `nvim-tree` and `fzf-lua` by registering `mini.icons` as the `nvim-web-devicons` provider.

**Architecture:** Call `MiniIcons.mock_nvim_web_devicons()` immediately after `mini.icons` setup, and load `plugins.mini-plugins` before `plugins.nvim-tree` and `plugins.fzf-lua` so the mock is in `package.loaded` when those plugins resolve `require("nvim-web-devicons")`.

**Tech Stack:** Neovim 0.12+, Lua, `mini.nvim` (already vendored via `vim.pack`).

**Spec:** `docs/superpowers/specs/2026-05-08-icons-nvim-design.md`

**Testing note:** This codebase has no automated test framework. Verification is interactive (Neovim Ex commands + visual smoke test). Each task therefore replaces "run failing test" with the equivalent Neovim probe.

---

## File Structure

- Modify: `lua/plugins/mini-plugins.lua` — add one mock call after `mini.icons` setup.
- Modify: `lua/plugins/init.lua` — reorder `require("plugins.mini-plugins")` to run before `nvim-tree` and `fzf-lua`; add a one-line ordering comment.

No new files. No file moves.

---

### Task 1: Confirm baseline (no icons)

**Files:** none — read-only Neovim probe.

- [ ] **Step 1: Open Neovim in repo root**

Run: `nvim` from `/Users/pwlazlo/.config/nvim`.

- [ ] **Step 2: Confirm `nvim-web-devicons` is NOT registered**

In Neovim command line:

```vim
:lua print(package.loaded["nvim-web-devicons"])
```

Expected: `nil`.

- [ ] **Step 3: Confirm `nvim-tree` shows no per-type icons**

```vim
:NvimTreeOpen
```

Expected: file rows display without filetype glyphs (only folder/file fallback or plain text).

- [ ] **Step 4: Confirm `fzf-lua files` shows no per-type icons**

```vim
:lua require("fzf-lua").files()
```

Expected: rows show no filetype glyph prefix.

- [ ] **Step 5: Quit Neovim**

```vim
:qa!
```

No commit. This task only establishes the failing baseline.

---

### Task 2: Register mini.icons as the devicons provider

**Files:**
- Modify: `lua/plugins/mini-plugins.lua:13`

- [ ] **Step 1: Add the mock call**

After the existing line `require("mini.icons").setup({})`, append `MiniIcons.mock_nvim_web_devicons()`. The full file becomes:

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
MiniIcons.mock_nvim_web_devicons()
```

- [ ] **Step 2: Reload Neovim and confirm the mock is registered**

Restart Neovim, then run:

```vim
:lua print(package.loaded["nvim-web-devicons"] ~= nil)
```

Expected: `true`.

- [ ] **Step 3: Confirm icons still missing in `nvim-tree`/`fzf-lua`**

```vim
:NvimTreeOpen
```

Expected: still no per-type icons. (Reason: `plugins.nvim-tree` ran before `plugins.mini-plugins`, so it cached the missing provider during its own initialization.) This confirms Task 3 is needed.

- [ ] **Step 4: Quit without committing**

```vim
:qa!
```

No commit yet — Tasks 2 and 3 ship together.

---

### Task 3: Load mini-plugins before consumers

**Files:**
- Modify: `lua/plugins/init.lua:95` (move `require("plugins.mini-plugins")` upward, add ordering comment)

- [ ] **Step 1: Reorder the plugin-config requires**

Replace the current block (lines 88–103 in the current file):

```lua
-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

-- Load plugin configurations in order
require("plugins.colorscheme")
require("plugins.treesitter")
require("plugins.completion")
require("plugins.lsp")
require("plugins.nvim-tree")
require("plugins.fzf-lua")
require("plugins.mini-plugins")
require("plugins.gitsigns")
require("plugins.tasks")
require("plugins.dap")
require("plugins.test")
require("plugins.navigation")
require("plugins.which-key")
require("plugins.snacks")
require("plugins.kilo")
```

With:

```lua
-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

-- Load plugin configurations in order.
-- mini-plugins must run before nvim-tree/fzf-lua: it registers
-- MiniIcons.mock_nvim_web_devicons(), which those plugins resolve at init
-- time via require("nvim-web-devicons"). See NER-116.
require("plugins.colorscheme")
require("plugins.treesitter")
require("plugins.completion")
require("plugins.lsp")
require("plugins.mini-plugins")
require("plugins.nvim-tree")
require("plugins.fzf-lua")
require("plugins.gitsigns")
require("plugins.tasks")
require("plugins.dap")
require("plugins.test")
require("plugins.navigation")
require("plugins.which-key")
require("plugins.snacks")
require("plugins.kilo")
```

- [ ] **Step 2: Restart Neovim and verify provider is registered before consumers**

```vim
:lua print(package.loaded["nvim-web-devicons"] ~= nil)
```

Expected: `true`.

- [ ] **Step 3: Verify `nvim-tree` shows per-type icons**

```vim
:NvimTreeOpen
```

Expected: file rows show per-filetype glyphs (e.g. distinct glyph for `.lua`, `.json`, `.md`; folder glyph for directories).

- [ ] **Step 4: Verify `fzf-lua files` shows per-type icons**

```vim
:lua require("fzf-lua").files()
```

Expected: each row prefixed with a per-filetype glyph.

- [ ] **Step 5: Regression check — statusline still renders glyphs**

Open any Lua file in the repo. Inspect the statusline.

Expected: mode icon, git branch glyph, filetype glyph (Lua), file-size glyph all render as before.

- [ ] **Step 6: Commit**

```bash
git add lua/plugins/mini-plugins.lua lua/plugins/init.lua
git commit -m "feat(icons): use mini.icons as nvim-web-devicons provider

Call MiniIcons.mock_nvim_web_devicons() so nvim-tree and fzf-lua pick up
icons from mini.icons. Load plugins.mini-plugins before its consumers so
the mock is registered before they resolve require(\"nvim-web-devicons\").

Refs NER-116"
```

---

### Task 4: Update KEYBINDINGS doc reference (optional sanity)

**Files:**
- Read-only check: `KEYBINDINGS.md`

- [ ] **Step 1: Skim `KEYBINDINGS.md` for any icon-related notes**

Run:

```bash
grep -n -i "icon" KEYBINDINGS.md
```

Expected: no matches. If matches surface, decide whether to update; otherwise skip the rest of this task.

No commit unless edits were made.

---

## Self-Review

**Spec coverage:**
- Spec "Changes → mini-plugins.lua" → Task 2.
- Spec "Changes → init.lua" → Task 3.
- Spec "Verification" steps 1–4 → covered across Tasks 1–3 (baseline, post-Task-2 partial check, full verification in Task 3).
- Spec "Risks → load order regression" → Task 3 Step 1 adds the explanatory comment.

**Placeholders:** none — all code shown verbatim, no TBDs.

**Type consistency:** `MiniIcons.mock_nvim_web_devicons()` is the same call referenced in spec and in every step.

No outstanding gaps.
