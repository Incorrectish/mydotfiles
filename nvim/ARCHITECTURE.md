# Neovim Configuration Architecture

> Reference document for AI assistants editing this config.

## Directory Structure

```
~/.config/nvim/
├── init.lua                 # Entry point - loads all modules
└── lua/user/
    ├── plugins.lua          # Plugin specifications (lazy.nvim)
    ├── options.lua          # Vim options (tabstop, number, etc.)
    ├── keymaps.lua          # All keybindings (which-key based)
    ├── telescope.lua        # Fuzzy finder setup + keymaps
    ├── treesitter.lua       # Syntax highlighting + textobjects
    ├── lsp.lua              # Language servers + Mason
    ├── completion.lua       # Autocompletion (nvim-cmp)
    ├── dashboard.lua        # Start screen
    ├── lualine.lua          # Status line
    ├── nvim-tree.lua        # File explorer
    ├── leap.lua             # Motion plugin
    └── harpoon.lua          # File bookmarks
```

## What to Edit for Common Tasks

| Task | File(s) to Edit |
|------|-----------------|
| Add/remove a plugin | `plugins.lua` |
| Change vim options (tabs, line numbers) | `options.lua` |
| Add/modify keybindings | `keymaps.lua` |
| Configure LSP servers | `lsp.lua` (servers table) |
| Add formatters/linters | `plugins.lua` (conform.nvim config) |
| Change colorscheme | `init.lua` (colorscheme line) |
| Modify completion behavior | `completion.lua` |
| Change telescope defaults | `telescope.lua` |
| Edit treesitter languages | `treesitter.lua` (ensure_installed) |
| Modify status line | `lualine.lua` |
| Change file explorer settings | `nvim-tree.lua` |

## File Responsibilities

### init.lua
- Sets leader key (space)
- Bootstraps lazy.nvim package manager
- Loads all modules in order
- Sets colorscheme
- Contains autocommands (yank highlight, formatexpr)

**Do not add plugin configs here** - use dedicated modules.

### plugins.lua
- All plugin specifications for lazy.nvim
- Organized by category (Git, LSP, UI, Navigation, etc.)
- Some plugins have inline config, others defer to modules
- `lsp_signature.setup()` called at end

**To add a plugin:** Add spec to appropriate category section.

### keymaps.lua
- Basic keymaps (j/k wrap, Space nop, diagnostics)
- Window navigation (Colemak: n/e/i/o = h/j/k/l)
- All which-key group definitions
- Groups: Buffer, Git, LSP, Find, Harpoon, Trouble, Window, Session

**Leader key groups:**
- `<leader>b` - Buffer operations
- `<leader>g` - Git operations
- `<leader>c` - LSP/Code operations
- `<leader>f` - Find (telescope)
- `<leader>h` - Harpoon
- `<leader>t` - Trouble diagnostics
- `<leader>w` - Window management
- `<leader>q` - Session management
- `<leader>e` - File explorer (single key)

### lsp.lua
- `on_attach` function with LSP keymaps
- Mason setup (must be before mason-lspconfig)
- Server configurations in `servers` table
- Capabilities setup for nvim-cmp

**To add an LSP server:** Add to `servers` table with settings.

### telescope.lua
- Telescope setup with ripgrep args
- `find_git_root()` helper
- All `<leader>s*` search keymaps
- Buffer/oldfiles keymaps

### treesitter.lua
- Treesitter setup (ensure_installed languages)
- Textobjects configuration
- Select keymaps: `aa/ia` (parameter), `af/if` (function), `ac/ic` (class)
- Move keymaps: `]m/[m` (function), `]]/[[` (class)
- Swap keymaps: `<leader>a/A` (swap parameters)

### completion.lua
- nvim-cmp setup
- LuaSnip configuration
- Tab/S-Tab completion navigation
- Sources: nvim_lsp, luasnip, path, orgmode

### options.lua
- All `vim.opt` settings
- Backup, clipboard, tabs, UI options
- Does not contain keymaps

## Plugin Manager

Uses **lazy.nvim**. Plugins auto-install on first launch.

Commands:
- `:Lazy` - Open plugin manager UI
- `:Lazy sync` - Update all plugins
- `:Lazy clean` - Remove unused plugins

## Key Patterns

1. **Colemak layout** - Window navigation uses n/e/i/o instead of h/j/k/l
2. **Leader = Space** - All leader keymaps use space
3. **Which-key** - All leader keymaps show in popup menu
4. **Telescope** - Primary fuzzy finder for everything

## Dependencies Between Files

```
init.lua
  └── plugins.lua (must load first - sets up lazy.nvim)
        └── All other modules depend on plugins being available

lsp.lua depends on:
  - telescope (for lsp_definitions, lsp_references, etc.)
  - cmp_nvim_lsp (for capabilities)
  - mason, mason-lspconfig, lspconfig, neodev

keymaps.lua depends on:
  - which-key
  - gitsigns, harpoon, persistence (for leader keymaps)

telescope.lua depends on:
  - telescope, telescope.builtin, telescope.themes

treesitter.lua depends on:
  - nvim-treesitter
  - nvim-treesitter-textobjects
```

## Notes for AI Editors

1. **Don't duplicate keymaps** - Check keymaps.lua before adding new ones
2. **Plugin configs belong in plugins.lua** unless complex enough for own module
3. **LSP keymaps are in lsp.lua** (buffer-local on attach)
4. **Telescope keymaps are in telescope.lua** (except which-key `<leader>f` group)
5. **Test changes** with `nvim --headless -c 'qall'` to check for errors
6. **Colorscheme** is `incorrectish_colors` - set in init.lua and plugins.lua
