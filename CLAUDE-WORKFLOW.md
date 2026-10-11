# Claude Code workflow in Neovim

This config integrates the `claude` CLI through
[claudecode.nvim](https://github.com/coder/claudecode.nvim). Neovim starts a
WebSocket server (MCP) on launch and the CLI connects to it, so Claude sees
your open buffers, current selection and diagnostics, and proposes edits as
native diffs you accept or reject inside the editor.

## Prerequisites

- `claude` CLI on `PATH`: `npm i -g @anthropic-ai/claude-code`, then `claude`
  once in a shell to log in. The plugin reuses that login; no API key lives in
  the Neovim config.
- `snacks.nvim` (already part of this config) renders the sidebar.

## Keymaps (`<leader>a`, group `ai/claude`)

| Mode | Key | Action |
|---|---|---|
| n | `<leader>ac` | Toggle Claude Code sidebar |
| n | `<leader>af` | Focus the sidebar |
| n | `<leader>ar` | Resume a previous session (picker) |
| n | `<leader>aC` | Continue the most recent session |
| n | `<leader>am` | Select Claude model |
| n | `<leader>ab` | Add current buffer as `@file` context |
| v | `<leader>as` | Send selection to Claude |
| n (nvim-tree) | `<leader>as` | Add file under cursor as context |
| n | `<leader>aa` | Accept proposed diff |
| n | `<leader>ad` | Deny proposed diff |

Inside the sidebar the terminal behaves like any snacks terminal: `<Esc>`
leaves terminal mode and hides it, `<leader>ac` brings it back.

## Example: fix a bug in the file you are editing

1. Open the file and jump to the suspicious function.
2. Select the function in visual mode and press `<leader>as`. The selection
   lands in the prompt as a reference to the exact lines.
3. Press `<leader>ab` on any other buffer that gives context (a test, a
   caller). Each one is added as `@file`.
4. `<leader>af`, type the request, e.g. `This throws on empty input, write a
   failing test first, then fix it.` Enter.
5. Claude edits land as a diff tab: review, then `<leader>aa` to accept or
   `<leader>ad` to reject. Accepted changes are written to the buffer, not
   committed.
6. Run the tests with `<leader>tf`, commit with LazyGit (`<leader>gg`).

## Example: explore an unfamiliar project

1. In nvim-tree (`<leader>e`) move to `README.md` and press `<leader>as`,
   repeat for the entry-point file.
2. `<leader>ac`, ask `Explain how a request flows from the entry point to the
   database layer.`
3. When Claude names a file, open it with `<leader>ff`; the plugin tracks the
   active buffer, so follow-up questions refer to what you are looking at.

## Example: pick up yesterday's session

`<leader>aC` reopens the last conversation for this project with its full
context. `<leader>ar` shows a picker when there were several.

## Troubleshooting

- `claude executable not found`: install the CLI (see above) and restart
  Neovim; the plugin does not install it.
- CLI started outside Neovim does not see the editor: the connection is
  per-Neovim via a lock file in `~/.claude/ide/<port>.lock`. Start `claude`
  from the sidebar (`<leader>ac`) or run `/ide` inside the CLI and pick this
  Neovim instance.
- Stale lock files after a crash are safe to delete from `~/.claude/ide/`.
- `:ClaudeCodeStatus` shows whether the server is running and on which port.
