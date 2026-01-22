require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-repeat',

  {
    'vyfor/cord.nvim',
    build = './build || .\\build',
    event = 'VeryLazy',
    opts = {}, -- calls require('cord').setup()
  },
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- better buffer deletion
  "famiu/bufdelete.nvim",

  'ray-x/lsp_signature.nvim',
  'ThePrimeagen/vim-be-good',
  'akinsho/org-bullets.nvim',
  -- lazy.nvim
  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     -- add any options here
  --   },
  --   dependencies = {
  --     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
  --     "MunifTanjim/nui.nvim",
  --     -- OPTIONAL:
  --     --   `nvim-notify` is only needed, if you want to use the notification view.
  --     --   If not available, we use `mini` as the fallback
  --     "rcarriga/nvim-notify",
  --   }
  -- },
  -- lazy.nvim
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {}
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {},
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  },
  {
    'stevearc/conform.nvim',
    opts = {},
  },
  {
    "vhyrro/luarocks.nvim",
    priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
    config = true,
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
  },
  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },
  {
    'nvim-orgmode/orgmode',
    event = 'VeryLazy',
    ft = { 'org' },
    config = function()
      -- Setup orgmode
      require('orgmode').setup({
        org_agenda_files = '~/orgfiles/**/*',
        org_default_notes_file = '~/orgfiles/refile.org',
      })

      -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
      -- add ~org~ to ignore_install
      -- require('nvim-treesitter.configs').setup({
      --   ensure_installed = 'all',
      --   ignore_install = { 'org' },
      -- })
    end,
  },
  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-path',    -- path completions
      'hrsh7th/cmp-cmdline', -- cmdline completions
      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },
  -- {
  --   "nvim-neorg/neorg",
  --   dependencies = { "luarocks.nvim" },
  --   version = "*",
  --   config = function()
  --     require("neorg").setup {
  --       load = {
  --         ["core.defaults"] = {},
  --         ["core.concealer"] = {},
  --         ["core.dirman"] = {
  --           config = {
  --             workspaces = {
  --               notes = "~/.notes",
  --             },
  --             default_workspace = ".notes",
  --           },
  --         },
  --       },
  --     }
  --
  --     vim.wo.foldlevel = 99
  --     vim.wo.conceallevel = 2
  --   end,
  -- },

  {
    "leath-dub/snipe.nvim",
    keys = {
      { "gb", function() require("snipe").open_buffer_menu() end, desc = "Open Snipe buffer menu" }
    },
    opts = {
      ui = {
        position = "center",
      },
      hints = {
        -- Charaters to use for hints (NOTE: make sure they don't collide with the navigation keymaps)
        dictionary = "sadflewcmpghio",
      },
      navigate = {
        -- When the list is too long it is split into pages
        -- `[next|prev]_page` options allow you to navigate
        -- this list
        next_page = "J",
        prev_page = "K",

        -- You can also just use normal navigation to go to the item you want
        -- this option just sets the keybind for selecting the item under the
        -- cursor
        under_cursor = "<C-m>",

        -- In case you changed your mind, provide a keybind that lets you
        -- cancel the snipe and close the window.
        cancel_snipe = "q",
      },
      -- Define the way buffers are sorted by default
      -- Can be any of "default" (sort buffers by their number) or "last" (sort buffers by last accessed)
      sort = "last"
    },
  },
  -- {
  --   "OXY2DEV/markview.nvim",
  --   lazy = false, -- Recommended
  --   -- ft = "markdown" -- If you decide to lazy-load anyway
  --
  --   dependencies = {
  --     -- You will not need this if you installed the
  --     -- parsers manually
  --     -- Or if the parsers are in your $RUNTIMEPATH
  --     "nvim-treesitter/nvim-treesitter",
  --
  --     "nvim-tree/nvim-web-devicons"
  --   }
  -- },
  "tpope/vim-surround",
  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim' },
  {
    "folke/trouble.nvim",
    dependencies = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup()
    end
  },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- -- normal mode
        -- map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        -- map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        -- map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        -- map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        -- map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        -- map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        -- map('n', '<leader>hb', function()
        --   gs.blame_line { full = false }
        -- end, { desc = 'git blame line' })
        -- map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        -- map('n', '<leader>hD', function()
        --   gs.diffthis '~'
        -- end, { desc = 'git diff against last commit' })
        --
        -- -- Toggles
        -- map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        -- map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })
        --
        -- Text object
        -- map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },
  {
    "incorrectish/incorrectish_colors",
    opts = {
      style = "light",
    },
  },
  {
    "https://github.com/navarasu/onedark.nvim",
  },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",  -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed, not both.
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim", }
  },
  {
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  {
    'numToStr/Comment.nvim',
    opts = {
      toggler = {
        ---Line-comment toggle keymap
        line = 'gcc',
        ---Block-comment toggle keymap
        block = 'g/c',
      },
      ---LHS of operator-pending mappings in NORMAL and VISUAL mode
      opleader = {
        ---Line-comment keymap
        line = 'gc',
        ---Block-comment keymap
        block = 'g/',
      },
    }
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-treesitter-context'
    },
    build = ':TSUpdate',
  },
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icons
    },
  },

  {
    'nvimdev/dashboard-nvim',
  },
  {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  },
  {
    "norcalli/nvim-colorizer.lua",
  },
  {
    "hedyhli/outline.nvim",
    config = function()
      require("outline").setup {
        -- Your setup opts here (leave empty to use defaults)
      }
    end,
  },
  "tpope/vim-repeat",
  "ggandor/leap.nvim"
  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})

require("oil").setup()
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
require("lsp_signature").setup()
-- require("noice").setup({
--   lsp = {
--     -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
--     override = {
--       ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
--       ["vim.lsp.util.stylize_markdown"] = true,
--       ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
--     },
--     signature = {
--       enabled = false,
--     }
--   },
--   notify = {
--     enabled = false,
--   },
--   messages = {
--     enabled = false
--   },
--   -- you can enable a preset for easier configuration
--   presets = {
--     bottom_search = true, -- use a classic bottom cmdline for search
--     command_palette = true, -- position the cmdline and popupmenu together
--     long_message_to_split = true, -- long messages will be sent to a split
--     inc_rename = false, -- enables an input dialog for inc-rename.nvim
--     lsp_doc_border = false, -- add a border to hover docs and signature help
--   },
-- })
--
require('incorrectish_colors').setup {
  style = 'deep'
}
require('incorrectish_colors').load()


-- Keybindings
-- vim.api.nvim_set_keymap('n', '<leader>mtd', ':Neorg keybind norg core.norg.qol.todo_items.todo.task_done<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>mtt', ':Neorg keybind norg core.norg.qol.todo_items.todo.task_todo<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>mdd', ':Neorg keybind norg core.norg.qol.todo_items.todo.task_deadline<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>mnh', ':Neorg keybind norg core.norg.movement.next.heading<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>mph', ':Neorg keybind norg core.norg.movement.previous.heading<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>msd', ':Neorg keybind norg core.norg.qol.todo_items.todo.task_scheduled<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>mtt', ':Neorg keybind norg core.norg.qol.todo_items.todo.task_tag<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>mnc', ':Neorg keybind norg core.norg.capture<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>mne', ':Neorg keybind norg core.norg.edit<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>mtc', ':Neorg keybind norg core.norg.qol.todo_items.todo.task_cycle<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>mtb', ':Neorg keybind norg core.norg.qol.todo_items.todo.checkbox_toggle<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>mtoc', ':Neorg keybind norg core.qol.toc.generate<CR>', { noremap = true, silent = true })

-- require('akinsho/org-bullets.nvim').setup()
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- You can customize some of the format options for the filetype (:help conform.format)
    rust = { "rustfmt", lsp_format = "fallback" },
    -- Conform will run the first available formatter
    javascript = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
  },
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})

require('cord').setup {
  usercmds = true,           -- Enable user commands
  log_level = 'trace',       -- One of 'trace', 'debug', 'info', 'warn', 'error', 'off'
  timer = {
    interval = 1500,         -- Interval between presence updates in milliseconds (min 500)
    reset_on_idle = false,   -- Reset start timestamp on idle
    reset_on_change = false, -- Reset start timestamp on presence change
  },
  editor = {
    image = nil,                          -- Image ID or URL in case a custom client id is provided
    client = 'neovim',                    -- vim, neovim, lunarvim, nvchad, astronvim or your application's client id
    tooltip = 'The Superior Text Editor', -- Text to display when hovering over the editor's image
  },
  display = {
    show_time = true,             -- Display start timestamp
    show_repository = true,       -- Display 'View repository' button linked to repository url, if any
    show_cursor_position = false, -- Display line and column number of cursor's position
    swap_fields = false,          -- If enabled, workspace is displayed first
    swap_icons = false,           -- If enabled, editor is displayed on the main image
    workspace_blacklist = {},     -- List of workspace names that will hide rich presence
  },
  lsp = {
    show_problem_count = false, -- Display number of diagnostics problems
    severity = 1,               -- 1 = Error, 2 = Warning, 3 = Info, 4 = Hint
    scope = 'workspace',        -- buffer or workspace
  },
  idle = {
    enable = true, -- Enable idle status
    show_status = true, -- Display idle status, disable to hide the rich presence on idle
    timeout = 300000, -- Timeout in milliseconds after which the idle status is set, 0 to display immediately
    disable_on_focus = false, -- Do not display idle status when neovim is focused
    text = 'Idle', -- Text to display when idle
    tooltip = '💤', -- Text to display when hovering over the idle image
    icon = nil, -- Replace the default idle icon; either an asset ID or a URL
  },
  text = {
    viewing = 'Viewing {}',                    -- Text to display when viewing a readonly file
    editing = 'Editing {}',                    -- Text to display when editing a file
    file_browser = 'Browsing files in {}',     -- Text to display when browsing files (Empty string to disable)
    plugin_manager = 'Managing plugins in {}', -- Text to display when managing plugins (Empty string to disable)
    lsp_manager = 'Configuring LSP in {}',     -- Text to display when managing LSP servers (Empty string to disable)
    vcs = 'Committing changes in {}',          -- Text to display when using Git or Git-related plugin (Empty string to disable)
    workspace = 'In {}',                       -- Text to display when in a workspace (Empty string to disable)
  },
  buttons = {
    {
      label = 'View Repository', -- Text displayed on the button
      url = 'git',               -- URL where the button leads to ('git' = automatically fetch Git repository URL)
    },
    -- {
    --   label = 'View Plugin',
    --   url = 'https://github.com/vyfor/cord.nvim',
    -- }
  },
  assets = nil, -- Custom file icons, see the wiki*
  -- assets = {
  --   lazy = {                                 -- Vim filetype or file name or file extension = table or string
  --     name = 'Lazy',                         -- Optional override for the icon name, redundant for language types
  --     icon = 'https://example.com/lazy.png', -- Rich Presence asset name or URL
  --     tooltip = 'lazy.nvim',                 -- Text to display when hovering over the icon
  --     type = 'plugin_manager',               -- One of 'language', 'file_browser', 'plugin_manager', 'lsp_manager', 'vcs' or respective ordinals; defaults to 'language'
  --   },
  --   ['Cargo.toml'] = 'crates',
  -- },
}
