# Neovim, Zellij, Toggleterm, and Agent Tool Integration Plan

## Goals

- Make Neovim aware of whether it is running inside an active Zellij session.
- Only when Neovim is inside Zellij, enable shared keybindings for:
  - `Alt+n/e/i/o` for directional navigation
  - `Alt+Shift+N/E/I/O` for moving Neovim splits
  - `Ctrl-b h` for horizontal splits
  - `Ctrl-b v` for vertical splits
- Use Zellij autolock so these keys reach Neovim when Neovim is focused.
- Add a minimal floating terminal via `toggleterm.nvim` on `Ctrl+\`.
- Add an agent split workflow for `opencode`, and leave room for Claude Code to use the same pattern.

## Current State

- WezTerm already treats a pane as inside Zellij when the pane user var `ZELLIJ == "1"`.
- Zellij currently owns `Alt+n/e/i/o` in normal mode and `Ctrl-b` as a tmux-style prefix.
- Neovim currently has centralized mappings in `lua/user/keymaps.lua` and plugin registration in `lua/user/plugins.lua`.

## Implementation Plan

### 1. Zellij-side key ownership

- Install and configure `zellij-autolock` in Zellij.
- Configure it so panes running `nvim`, `vim`, and related editor commands automatically switch Zellij into locked mode.
- This is the mechanism that allows `Alt+n/e/i/o` and `Ctrl-b h/v` to reach Neovim instead of being consumed by Zellij.
- Keep manual unlock available so Zellij bindings can still be used intentionally.

### 2. Neovim-side Zellij detection

- Add a small helper module, likely `lua/user/zellij.lua`.
- In that module, detect active Zellij with `vim.env.ZELLIJ == "1"`.
- Only register the special navigation and split keymaps when that condition is true.

### 3. Unified directional navigation

- Add `Alt+n/e/i/o` mappings in Neovim for left/down/up/right.
- Behavior:
  - If a Neovim window exists in that direction, move within Neovim.
  - If Neovim is at the edge and `vim.env.ZELLIJ == "1"`, call Zellij to move pane focus in that direction.
  - If not in Zellij, do not register these bindings.
- Prefer explicit Zellij actions from Neovim over trying to emit raw passthrough key sequences.
- Candidate implementation: shell out to `zellij action move-focus left|down|up|right`.

### 4. Neovim split movement

- Add `Alt+Shift+N/E/I/O` mappings for moving the current Neovim split:
  - left: `<C-w>H`
  - down: `<C-w>J`
  - up: `<C-w>K`
  - right: `<C-w>L`
- These mappings should also only exist when Neovim is inside Zellij.

### 5. Conditional split creation

- Add `Ctrl-b h` for horizontal splits and `Ctrl-b v` for vertical splits.
- These should only be active when Neovim is inside Zellij.
- This preserves the requested shared muscle memory while avoiding conflicts outside that environment.

### 6. Toggleterm integration

- Add `akinsho/toggleterm.nvim`.
- Keep the configuration minimal:
  - floating terminal only
  - `Ctrl+\` toggles the terminal open and closed
  - reuse the same terminal instance within the current Neovim session
  - enable lightweight persistence options that preserve the terminal during the session
- Out of scope:
  - restoring terminal state after Neovim exits

### 7. Agent split helper

- Add one generic helper module for terminal-based coding agents, likely `lua/user/agent_term.lua`.
- This helper should:
  - open a dedicated split for a named tool command
  - reuse or focus the existing split if already open
  - toggle the split closed when appropriate
  - keep working directory behavior predictable

### 8. OpenCode integration

- Use a Neovim-native OpenCode frontend instead of a plain embedded terminal workflow.
- Preferred plugin: `sudo-tee/opencode.nvim`.
- Reason:
  - it is designed as a Neovim frontend with separate UI buffers
  - it better matches the goal of scrolling output with Vim bindings
  - it better matches the goal of editing the input area natively with Vim bindings
- Bind `<leader>oo` to open the OpenCode interface in another split.
- Keep the generic agent split helper only as a fallback or for tools that do not have a sufficiently native Neovim UI.
- Add a custom `gd` mapping in the OpenCode output buffer:
  - detect a file path under cursor or a mentioned file reference
  - open that file in the code split
  - prefer reusing the adjacent editing window when possible

### 9. Claude Code integration

- Use `coder/claudecode.nvim` instead of a plain terminal-split integration.
- Reason:
  - it is closer to a true editor integration than a raw CLI embed
  - it is a better fit for native Neovim interaction and editor-driven file opening
  - it aligns better with the goal of browsing Claude output and acting on referenced files from inside Neovim
- Proposed initial mapping:
  - `<leader>oc` for Claude Code
- If needed, keep a generic split-based launcher as a fallback for direct CLI access, but not as the default experience.

### 10. Native interaction goals

- Output navigation:
  - output views for Claude Code and OpenCode should be scrollable with standard Vim motions
- Input editing:
  - prompt/input areas should be real editable Neovim buffers where possible
- File navigation from agent output:
  - implement `gd` on file mentions in the OpenCode output buffer
  - if Claude Code exposes a comparable output buffer or reference action, map it similarly
  - if the plugin already provides a stronger built-in file-open action, use that instead of duplicating it

### 11. File changes

- Zellij:
  - update `zellij/config.kdl`
- Neovim:
  - update `lua/user/plugins.lua`
  - update `lua/user/keymaps.lua`
  - add `lua/user/zellij.lua`
  - add any plugin-specific integration files needed for OpenCode and Claude Code
  - add a small helper for file-reference opening if the OpenCode plugin does not already expose one

## Validation Plan

- Inside a Zellij session with Neovim focused:
  - `Alt+n/e/i/o` moves between Neovim windows first, then across Zellij panes at edges
  - `Alt+Shift+N/E/I/O` rearranges Neovim splits
  - `Ctrl-b h` and `Ctrl-b v` create Neovim splits
  - `Ctrl+\` toggles the floating terminal
  - `<leader>oo` opens a Neovim-native OpenCode interface in a split
  - `<leader>oc` opens Claude Code
  - OpenCode output is navigable with normal Vim motions
  - OpenCode input is editable with normal Vim editing
  - `gd` on a file mention in OpenCode opens the target file in the adjacent editing split
- Outside Zellij:
  - none of the conditional Zellij-specific bindings are registered
- Zellij autolock:
  - entering Neovim locks Zellij
  - leaving Neovim unlocks it

## Known Risk

- The keybinding design depends on Zellij autolock behaving reliably for Neovim-focused panes. This should be validated before finalizing the Neovim mappings.
- Plugin capability differences may require a small amount of custom glue for `gd` on file mentions, especially on the OpenCode side.
