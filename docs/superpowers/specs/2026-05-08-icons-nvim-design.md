# Popular Icon Set — Design Spec

**Date:** 2026-05-08
**Issue:** NER-116
**Status:** Approved

## Problem

Icons are not displayed across the editor: `nvim-tree` shows file entries
without per-type glyphs, `fzf-lua` pickers show no file icons. Both plugins
default to looking up `nvim-web-devicons`, which is not installed.

`mini.icons` is already loaded (via `mini.nvim`), but it acts standalone —
it is not registered as the icon provider for other plugins.

The statusline and the `snacks.dashboard` shortcut keys use hardcoded Nerd
Font glyphs and render correctly. They are out of scope.

## Approach

Use `mini.icons` as the icon provider for the entire config via its
`mock_nvim_web_devicons()` shim. The shim installs `mini.icons` under the
module name `nvim-web-devicons`, so any plugin that calls
`require("nvim-web-devicons")` transparently consumes `mini.icons` data.

This keeps the plugin set unchanged (no new dependency) and yields a single
consistent icon source across `nvim-tree`, `fzf-lua`, and any future
plugin that follows the de-facto devicons API.

## Changes

### `lua/plugins/mini-plugins.lua`

Add a single line after `require("mini.icons").setup({})`:

```lua
MiniIcons.mock_nvim_web_devicons()
```

### `lua/plugins/init.lua`

Move `require("plugins.mini-plugins")` so it runs **before**
`require("plugins.nvim-tree")` and `require("plugins.fzf-lua")`. The mock
must be installed before either plugin's first `require("nvim-web-devicons")`,
otherwise that lookup falls through to the real (missing) module and the
plugin caches `nil`.

Target order (relevant slice):

```
require("plugins.mini-plugins")  -- registers mock first
require("plugins.nvim-tree")
require("plugins.fzf-lua")
```

Other `mini-plugins` modules (`mini.ai`, `mini.comment`, …) have no
ordering constraint, so the move is safe.

## Out of scope

- Statusline glyphs (already work).
- `snacks.dashboard` keys icons (already work).
- Replacing `mini.icons` with `nvim-web-devicons` (rejected — adds a plugin
  for parity with what we already have).

## Verification

Manual smoke test after `chezmoi`-style apply / Neovim restart:

1. `:lua print(package.loaded["nvim-web-devicons"] ~= nil)` → `true`.
2. `<leader>e` opens `nvim-tree`; entries show per-filetype icons
   (e.g. Lua leaf, JSON braces, folder glyph).
3. `<leader>ff` opens `fzf-lua files`; rows show per-filetype icons.
4. Statusline still renders mode/git/filetype/size icons (regression check).

## Risks

- **Load order regression:** if a future contributor moves
  `mini-plugins` back below `nvim-tree`/`fzf-lua`, icons silently break.
  Mitigation: a one-line comment above the `mini-plugins` require explaining
  the ordering invariant.
