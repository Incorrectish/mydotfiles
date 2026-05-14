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
      { 'j-hui/fidget.nvim',       opts = {} },
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
  {
    'pwntester/octo.nvim',
    cmd = 'Octo',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      picker = 'telescope',
      enable_builtin = true,
      use_local_fs = true,
      default_remote = { 'origin', 'upstream' },
      file_panel = {
        size = 14,
        use_icons = true,
      },
      suppress_missing_scope = {
        projects_v2 = true,
      },
    },
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
  { 'nvim-lualine/lualine.nvim',           opts = {} },
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },
  { 'folke/which-key.nvim' },
  { 'folke/snacks.nvim',                   opts = {} },
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
  { 'kyazdani42/nvim-tree.lua',                  dependencies = { 'kyazdani42/nvim-web-devicons' } },
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
  { 'windwp/nvim-autopairs',  config = function() require('nvim-autopairs').setup {} end },

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
      local function opencode_sound_hook(event_name, _data)
        -- TODO: trigger your sound effect for this Opencode event.
      end

      local function install_opencode_history_windowing()
        local renderer = require('opencode.ui.renderer')
        local formatter = require('opencode.ui.formatter')
        local output_window = require('opencode.ui.output_window')
        local state = require('opencode.state')
        local config = require('opencode.config')

        local max_messages = vim.tbl_get(config, 'ui', 'output', 'rendering', 'max_rendered_messages')
        if not max_messages or max_messages <= 0 then
          return
        end

        local original_on_message_updated = renderer.on_message_updated

        local function get_rendered_session_slice(session_data)
          if #session_data <= max_messages then
            return session_data, 0
          end

          local start_idx = #session_data - max_messages + 1
          return vim.list_slice(session_data, start_idx, #session_data), start_idx - 1
        end

        local function render_history_truncated_banner(hidden_count)
          if hidden_count <= 0 then
            return
          end

          renderer._write_formatted_data({
            lines = { string.format('[%d older Opencode messages hidden]', hidden_count) },
            extmarks = {},
          })
        end

        renderer._render_full_session_data = function(session_data, prev_revert, revert)
          renderer.reset()

          if not state.active_session or not state.messages then
            return
          end

          local visible_session_data, hidden_count = get_rendered_session_slice(session_data)
          local revert_index = nil
          local set_mode_from_messages = not state.current_model

          render_history_truncated_banner(hidden_count)

          for i, msg in ipairs(visible_session_data) do
            if state.active_session.revert and state.active_session.revert.messageID == msg.info.id then
              revert_index = i
            end

            renderer.on_message_updated({ info = msg.info }, revert_index)

            for _, part in ipairs(msg.parts or {}) do
              renderer.on_part_updated({ part = part }, revert_index)
            end
          end

          if revert_index then
            renderer._write_formatted_data(formatter._format_revert_message(state.messages, revert_index))
          end

          if set_mode_from_messages then
            renderer._set_model_and_mode_from_messages()
          end

          renderer.scroll_to_bottom(true)

          if config.hooks and config.hooks.on_session_loaded then
            pcall(config.hooks.on_session_loaded, state.active_session)
          end
        end

        renderer.on_message_updated = function(properties, revert_index)
          local message = properties and properties.info
          local seen = false

          if message and message.id and state.messages then
            for _, existing in ipairs(state.messages) do
              if existing.info and existing.info.id == message.id then
                seen = true
                break
              end
            end
          end

          original_on_message_updated(properties, revert_index)

          if not seen and state.messages and #state.messages > max_messages and output_window.mounted() then
            renderer._render_full_session_data(state.messages)
          end
        end
      end

      require('opencode').setup {
        preferred_picker = 'snacks',
        preferred_completion = 'nvim-cmp',
        default_global_keymaps = false,
        context = {
          current_file = {
            enabled = false,
          },
        },
        hooks = {
          on_done_thinking = function(session)
            opencode_sound_hook('done_thinking', session)
          end,
          on_permission_requested = function(session)
            opencode_sound_hook('permission_requested', session)
          end,
        },
        keymap = {
          editor = {
            ['<leader>oo'] = { 'open_input', desc = 'OpenCode' },
            ['<leader>oi'] = { 'open_input', desc = 'OpenCode Input' },
            ['<leader>om'] = { 'select_agent', desc = 'OpenCode Select Mode' },
          },
          input_window = {
            ['<esc>'] = false,
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
          enable_treesitter_markdown = true,
          position = 'right',
          input_position = 'bottom',
          window_width = 0.5,
          persist_state = true,
          output = {
            rendering = {
              -- Set to nil to restore full-session rendering.
              max_rendered_messages = 10,
              on_data_rendered = function(buf, win)
                require('user.agents').refresh_opencode_rendering(buf, win)
              end,
            },
          },
          input = {
            auto_hide = false,
            text = {
              wrap = true,
            },
          },
        },
      }

      install_opencode_history_windowing()

      local group = vim.api.nvim_create_augroup('UserOpencodeSoundHooks', { clear = true })
      vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = 'OpencodeEvent:question.asked',
        callback = function(args)
          opencode_sound_hook('question_asked', args.data and args.data.event)
        end,
      })
      vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = 'OpencodeEvent:session.idle',
        callback = function(args)
          opencode_sound_hook('session_idle', args.data and args.data.event)
        end,
      })
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
        snacks_win_opts = {
          wo = {
            winhighlight = 'Normal:Normal,NormalNC:NormalNC,EndOfBuffer:EndOfBuffer',
          },
        },
      },
    },
    config = true,
  },

  -- Session
  { 'folke/persistence.nvim', event = 'BufReadPre' },

  -- Misc
  { 'vhyrro/luarocks.nvim',   priority = 1000,                                                    config = true },
  { 'm4xshen/hardtime.nvim',  dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' }, opts = {} },
  'ThePrimeagen/vim-be-good',
}, {})

-- Setup lsp_signature
require('lsp_signature').setup()
