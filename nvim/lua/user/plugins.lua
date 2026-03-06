require('lazy').setup({
  -- Git
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Utilities
  'tpope/vim-repeat',
  'tpope/vim-sleuth',
  'tpope/vim-surround',
  'famiu/bufdelete.nvim',

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'folke/neodev.nvim',
    },
  },
  'ray-x/lsp_signature.nvim',

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'rafamadriz/friendly-snippets',
    },
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter-context' },
    build = ':TSUpdate',
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
    },
  },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    opts = {
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
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })
        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })
        -- Visual mode actions
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Reset git hunk' })
      end,
    },
  },
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = true,
  },

  -- UI
  {
    'incorrectish/incorrectish_colors',
    opts = { style = 'deep' },
    config = function(_, opts)
      require('incorrectish_colors').setup(opts)
      require('incorrectish_colors').load()
    end,
  },
  'navarasu/onedark.nvim',
  { 'nvim-lualine/lualine.nvim', opts = {} },
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },
  { 'folke/which-key.nvim' },
  { 'folke/snacks.nvim', opts = {} },
  { 'nvimdev/dashboard-nvim' },
  { 'norcalli/nvim-colorizer.lua' },
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      open_mapping = [[<c-\>]],
      insert_mappings = true,
      terminal_mappings = true,
      direction = 'float',
      persist_mode = true,
      start_in_insert = true,
      close_on_exit = false,
      float_opts = {
        border = 'curved',
      },
    },
  },

  -- File management
  { 'kyazdani42/nvim-tree.lua', dependencies = { 'kyazdani42/nvim-web-devicons' } },
  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup()
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    end,
  },

  -- Navigation
  { url = 'https://codeberg.org/andyg/leap.nvim' },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
  },
  {
    'leath-dub/snipe.nvim',
    keys = {
      { 'gb', function() require('snipe').open_buffer_menu() end, desc = 'Open Snipe buffer menu' },
    },
    opts = {
      ui = { position = 'center' },
      hints = { dictionary = 'sadflewcmpghio' },
      navigate = {
        next_page = 'J',
        prev_page = 'K',
        under_cursor = '<C-m>',
        cancel_snipe = 'q',
      },
      sort = 'last',
    },
  },

  -- Editing
  {
    'numToStr/Comment.nvim',
    opts = {
      toggler = { line = 'gcc', block = 'g/c' },
      opleader = { line = 'gc', block = 'g/' },
    },
  },
  { 'windwp/nvim-autopairs', config = function() require('nvim-autopairs').setup {} end },

  -- Diagnostics
  {
    'folke/trouble.nvim',
    dependencies = 'kyazdani42/nvim-web-devicons',
    config = function() require('trouble').setup() end,
  },
  {
    'hedyhli/outline.nvim',
    config = function() require('outline').setup {} end,
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'isort', 'black' },
          rust = { 'rustfmt', lsp_format = 'fallback' },
          javascript = { 'prettierd', 'prettier', stop_after_first = true },
          typescript = { 'prettierd', 'prettier', stop_after_first = true },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_format = 'fallback',
        },
      }
    end,
  },

  -- Org mode
  {
    'nvim-orgmode/orgmode',
    event = 'VeryLazy',
    ft = { 'org' },
    config = function()
      require('orgmode').setup {
        org_agenda_files = '~/orgfiles/**/*',
        org_default_notes_file = '~/orgfiles/refile.org',
      }
    end,
  },
  'akinsho/org-bullets.nvim',

  -- Markdown
  {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {
      anti_conceal = { enabled = false },
      file_types = { 'markdown', 'opencode_output' },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  },
  {
    'sudo-tee/opencode.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MeanderingProgrammer/render-markdown.nvim',
      'folke/snacks.nvim',
    },
    config = function()
      require('opencode').setup {
        preferred_picker = 'snacks',
        preferred_completion = 'nvim-cmp',
        default_global_keymaps = false,
        keymap = {
          editor = {
            ['<leader>oo'] = { 'open_input', desc = 'OpenCode' },
            ['<leader>oi'] = { 'open_input', desc = 'OpenCode Input' },
            ['<leader>ot'] = { 'toggle_focus', desc = 'OpenCode Toggle Focus' },
          },
          input_window = {
            ['<C-s>'] = { 'submit_input_prompt', mode = { 'n', 'i' }, desc = 'Submit prompt' },
            ['<C-j>'] = { 'submit_input_prompt', mode = { 'n', 'i' }, desc = 'Submit prompt' },
          },
          output_window = {
            ['gd'] = false,
            ['i'] = { 'focus_input', desc = 'Focus input' },
            ['gr'] = { 'references', desc = 'Browse code references' },
          },
        },
        ui = {
          position = 'right',
          input_position = 'bottom',
          window_width = 0.5,
          persist_state = true,
          input = {
            auto_hide = false,
            text = {
              wrap = true,
            },
          },
        },
      }
    end,
  },
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    opts = {
      terminal = {
        split_side = 'right',
        split_width_percentage = 0.5,
        provider = 'snacks',
      },
    },
    config = true,
  },

  -- Session
  { 'folke/persistence.nvim', event = 'BufReadPre' },

  -- Misc
  { 'vhyrro/luarocks.nvim', priority = 1000, config = true },
  { 'm4xshen/hardtime.nvim', dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' }, opts = {} },
  'ThePrimeagen/vim-be-good',
}, {})

-- Setup lsp_signature
require('lsp_signature').setup()
