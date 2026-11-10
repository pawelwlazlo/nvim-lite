# Navigating Diffs

This config ships two git tools that work together:

- **Diffview** (`sindrets/diffview.nvim`) shows changes side by side and resolves merge conflicts in a three-way view, similar to the diff and merge windows of JetBrains IDEs.
- **Neogit** (`NeogitOrg/neogit`) is the commit window: it lists changes, stages files and hunks, and writes the commit message.

Both open in a new tab page, so the file tree and the Claude Code sidebar stay untouched. Close the tab to get back to your layout.

The leader key is `Space`. All plugin keymaps below are the plugins' defaults unless stated otherwise; the full list for the current panel is always one keystroke away with `g?` in Diffview and `?` in Neogit.

## Opening a Diff

| Key / command | What it opens |
|---|---|
| `<leader>gv` | Diffview for the working tree: changed files on the left, side-by-side diff on the right |
| `<leader>gc` | Neogit status: changes, staging and commit |
| `:DiffviewOpen <rev>` | Diff of the working tree against any revision |
| `:DiffviewOpen <a>...<b>` | Diff between two branches or commits (from their merge base) |
| `:DiffviewFileHistory %` | Every commit that touched the current file, each with its diff |
| `:DiffviewFileHistory` | Commit history of the whole repository |
| `:DiffviewClose` | Close Diffview and its tab |

To compare your branch with `master` before opening a pull request, run:

```vim
:DiffviewOpen master...HEAD
```

To review the last three commits, run:

```vim
:DiffviewOpen HEAD~3
```

## Two-Pane Diff

The default layout puts the old version on the left and the new one on the right. The panes scroll together, and Neovim aligns moved lines and highlights changed characters within a line (`diffopt` contains `linematch:60` and `inline:char`).

### Moving Between Changes

| Key | Action |
|---|---|
| `]c` | Next change in the file |
| `[c` | Previous change in the file |
| `<Tab>` | Diff of the next file in the list |
| `<S-Tab>` | Diff of the previous file in the list |

### Moving Changes Between Panes

These are built-in Vim diff commands, so they also work in any `:diffthis` view. They are the keyboard counterpart of the arrows next to a change in JetBrains IDEs.

| Key | Action |
|---|---|
| `do` | Diff obtain: pull the change under the cursor from the other pane into this one |
| `dp` | Diff put: push the change under the cursor from this pane into the other one |

Only the right-hand pane of a working-tree diff is your real file; changes put into it are saved with `:w` like any edit.

### File Panel

| Key | Action |
|---|---|
| `<CR>` or `o` | Open the diff of the file under the cursor |
| `-` | Stage or unstage the file under the cursor |
| `S` | Stage all files |
| `U` | Unstage all files |
| `X` | Restore the file to the left-hand version (discards your changes) |
| `L` | Show the commit log for the current range |
| `<leader>e` | Focus the file panel |
| `<leader>b` | Show or hide the file panel |
| `g<C-x>` | Switch between the horizontal and vertical layout |
| `g?` | Help for the current panel |

## Merge Conflicts in Three Panes

When a merge, rebase or cherry-pick stops on conflicts, `<leader>gv` (or `:DiffviewOpen`) opens the conflicted files in the merge tool. The default layout has three panes:

| Left | Middle | Right |
|---|---|---|
| OURS (your branch) | the result file you edit and save | THEIRS (the incoming branch) |

The conflict keymaps work in any of the three panes and always change the middle one.

### Resolving One Conflict

| Key | Action |
|---|---|
| `]x` | Next conflict |
| `[x` | Previous conflict |
| `<leader>co` | Take the OURS version |
| `<leader>ct` | Take the THEIRS version |
| `<leader>cb` | Take the BASE version (the common ancestor) |
| `<leader>ca` | Keep all versions, one after another |
| `dx` | Delete the whole conflict region |

### Resolving a Whole File

| Key | Action |
|---|---|
| `<leader>cO` | Take OURS for every conflict in the file |
| `<leader>cT` | Take THEIRS for every conflict in the file |
| `<leader>cB` | Take BASE for every conflict in the file |
| `<leader>cA` | Keep all versions for every conflict in the file |
| `dX` | Delete every conflict region in the file |

Hand edits in the middle pane are fine too; `do` and `dp` work there as in the two-pane view. When a file is resolved, save it with `:w` and stage it with `-` in the file panel. After the last file, continue the merge or rebase from Neogit or from the shell.

### Other Merge Layouts

Pressing `g<C-x>` cycles through the merge layouts Diffview supports:

| Layout | Panes |
|---|---|
| `diff3_horizontal` (default) | OURS, result, THEIRS side by side |
| `diff3_vertical` | the same three panes stacked |
| `diff3_mixed` | OURS and THEIRS on top, result below |
| `diff4_mixed` | OURS, BASE and THEIRS on top, result below |
| `diff1_plain` | only the result file with conflict markers |

The four-pane `diff4_mixed` layout is the one to pick when you need to see what both sides changed relative to the common ancestor.

## Neogit: Staging and Committing

| Key | Action |
|---|---|
| `<Tab>` | Expand or collapse the file or hunk under the cursor |
| `s` | Stage the file or hunk under the cursor (in visual mode: the selected lines) |
| `u` | Unstage the file or hunk under the cursor |
| `S` | Stage all unstaged changes |
| `U` | Unstage all staged changes |
| `x` | Discard the change under the cursor |
| `<CR>` | Open the file at the change |
| `d d` | Open the file under the cursor in Diffview (`d` opens the diff menu, the second `d` picks "this") |
| `d s` / `d u` | Open all staged / unstaged changes in Diffview |
| `c c` | Start a commit: opens the commit message buffer |
| `P` / `p` | Push / pull menus |
| `b` | Branch menu |
| `l` | Log menu |
| `?` | All available actions |
| `q` | Close Neogit |

In the commit message buffer, `<C-c><C-c>` (or `:wq`) creates the commit and `<C-c><C-k>` aborts it.

## Keymap Overlaps

Diffview sets its keymaps only in its own buffers, and there they take precedence over the global keymaps of this config:

| Key | Global meaning | Inside Diffview |
|---|---|---|
| `<leader>e` | Toggle the file tree | Focus the Diffview file panel |
| `<leader>b` | (free) | Show or hide the Diffview file panel |
| `<leader>ca` | LSP code actions (in buffers with an LSP attached) | Keep all versions of a conflict |
| `<leader>c` | Clear search highlight | Waits for the next key, because `<leader>co`, `<leader>ct` and others start with it |

Outside the Diffview tab every key keeps its global meaning.

## Other Diff Tools in This Config

| Key | Tool | Use it for |
|---|---|---|
| `<leader>hd` | Gitsigns | Quick diff of the current file against `HEAD` |
| `<leader>hp` | Gitsigns | Preview the hunk under the cursor |
| `<leader>gg` | Lazygit | Full git TUI in a floating window |

The full keymap list of the config is in `KEYBINDINGS.md`.
