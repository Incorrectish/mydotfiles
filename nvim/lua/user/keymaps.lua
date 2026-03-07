-- All keymaps consolidated

local wk = require('which-key')
local zellij = require('user.zellij')
require('user.agents').setup()

-- Basic keymaps
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = '[D]iagnostics [L]ist' })
vim.keymap.set('n', '<leader>oo', function() require('opencode.api').open_input() end, { desc = 'OpenCode' })
vim.keymap.set('n', '<leader>oi', function() require('opencode.api').open_input() end, { desc = 'OpenCode Input' })
vim.keymap.set('n', '<leader>ot', function() require('opencode.api').toggle_focus() end, { desc = 'OpenCode Toggle Focus' })
vim.keymap.set('n', '<leader>oc', '<cmd>ClaudeCodeFocus<cr>', { desc = 'Claude Code' })
vim.keymap.set('n', '<leader>nv', require('user.agents').open_claude_reference_under_cursor, { desc = 'Open file under cursor from agent output' })
vim.keymap.set('n', '<leader>np', require('user.agents').open_claude_prompt_scratch, { desc = 'Claude prompt scratch' })
vim.keymap.set({ 'n', 't' }, '<C-e>', function()
  local agents = require('user.agents')
  if agents.is_current_claude_terminal() then
    agents.open_claude_prompt_scratch()
    return
  end

  local keys = vim.api.nvim_replace_termcodes('<C-e>', true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end, { desc = 'Claude prompt scratch from Claude terminal' })

-- Window navigation (Colemak)
vim.keymap.set('n', '<c-w>n', '<c-w>h')
vim.keymap.set('n', '<c-w>e', '<c-w>j')
vim.keymap.set('n', '<c-w>i', '<c-w>k')
vim.keymap.set('n', '<c-w>o', '<c-w>l')

if zellij.is_active() then
  vim.keymap.set({ 'n', 'i', 't' }, '<M-n>', function() zellij.focus_any('n') end, { desc = 'Left (Neovim/Zellij)' })
  vim.keymap.set({ 'n', 'i', 't' }, '<M-e>', function() zellij.focus_any('e') end, { desc = 'Down (Neovim/Zellij)' })
  vim.keymap.set({ 'n', 'i', 't' }, '<M-i>', function() zellij.focus_any('i') end, { desc = 'Up (Neovim/Zellij)' })
  vim.keymap.set({ 'n', 'i', 't' }, '<M-o>', function() zellij.focus_any('o') end, { desc = 'Right (Neovim/Zellij)' })

  vim.keymap.set({ 'n', 'i', 't' }, '<M-N>', function() zellij.move_split_any('N') end, { desc = 'Move split left' })
  vim.keymap.set({ 'n', 'i', 't' }, '<M-E>', function() zellij.move_split_any('E') end, { desc = 'Move split down' })
  vim.keymap.set({ 'n', 'i', 't' }, '<M-I>', function() zellij.move_split_any('I') end, { desc = 'Move split up' })
  vim.keymap.set({ 'n', 'i', 't' }, '<M-O>', function() zellij.move_split_any('O') end, { desc = 'Move split right' })

  vim.keymap.set({ 'n', 'i', 't' }, '<C-b>h', function() zellij.create_split('horizontal') end, { desc = 'Horizontal split' })
  vim.keymap.set({ 'n', 'i', 't' }, '<C-b>v', function() zellij.create_split('vertical') end, { desc = 'Vertical split' })
end

vim.keymap.set('t', '<C-]>', [[<C-\><C-n>]], { desc = 'Terminal normal mode' })

-- Format expression
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

-- Which-key groups
wk.add({
  -- Buffer
  { '<leader>b', group = 'Buffer' },
  { '<leader>bk', '<cmd>Bdelete<cr>', desc = 'Kill' },
  { '<leader>bl', '<cmd>buffers<cr>', desc = 'Buffers' },
  { '<leader>bn', '<cmd>bnext<cr>', desc = 'Next' },
  { '<leader>bp', '<cmd>bprevious<cr>', desc = 'Previous' },
  { '<leader>bf', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },

  -- Git
  { '<leader>g', group = 'Git' },
  { '<leader>gg', '<cmd>Neogit<CR>', desc = 'Neogit' },
  { '<leader>gj', "<cmd>lua require 'gitsigns'.next_hunk()<cr>", desc = 'Next Hunk' },
  { '<leader>gk', "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", desc = 'Prev Hunk' },
  { '<leader>gl', "<cmd>lua require 'gitsigns'.blame_line()<cr>", desc = 'Blame' },
  { '<leader>gp', "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", desc = 'Preview Hunk' },
  { '<leader>gr', "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", desc = 'Reset Hunk' },
  { '<leader>gR', "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", desc = 'Reset Buffer' },
  { '<leader>gs', "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", desc = 'Stage Hunk' },
  { '<leader>gu', "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", desc = 'Undo Stage Hunk' },
  { '<leader>go', '<cmd>Telescope git_status<cr>', desc = 'Open changed file' },
  { '<leader>gb', '<cmd>Telescope git_branches<cr>', desc = 'Checkout branch' },
  { '<leader>gc', '<cmd>Telescope git_commits<cr>', desc = 'Checkout commit' },
  { '<leader>gd', '<cmd>Gitsigns diffthis HEAD<cr>', desc = 'Diff' },

  -- LSP
  { '<leader>c', group = 'LSP' },
  { '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', desc = 'Code Action' },
  { '<leader>cd', '<cmd>Telescope lsp_document_diagnostics<cr>', desc = 'Document Diagnostics' },
  { '<leader>cw', '<cmd>Telescope lsp_workspace_diagnostics<cr>', desc = 'Workspace Diagnostics' },
  { '<leader>cf', "<cmd>lua require('conform').format()<cr>", desc = 'Format' },
  { '<leader>ci', '<cmd>LspInfo<cr>', desc = 'Info' },
  { '<leader>cI', '<cmd>LspInstallInfo<cr>', desc = 'Installer Info' },
  { '<leader>cj', '<cmd>lua vim.diagnostic.goto_next()<CR>', desc = 'Next Diagnostic' },
  { '<leader>ck', '<cmd>lua vim.diagnostic.goto_prev()<cr>', desc = 'Prev Diagnostic' },
  { '<leader>cl', '<cmd>lua vim.lsp.codelens.run()<cr>', desc = 'CodeLens Action' },
  { '<leader>cO', '<cmd>Outline<cr>', desc = 'Symbol Outline' },
  { '<leader>cq', '<cmd>lua vim.diagnostic.setloclist()<cr>', desc = 'Quickfix' },
  { '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<cr>', desc = 'Rename' },
  { '<leader>cs', '<cmd>Telescope lsp_document_symbols<cr>', desc = 'Document Symbols' },
  { '<leader>cS', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', desc = 'Workspace Symbols' },

  -- File explorer
  { '<leader>e', '<cmd>NvimTreeToggle<cr>', desc = 'File Explorer' },

  -- Find
  { '<leader>f', group = 'Find' },
  { '<leader>fr', '<cmd>Telescope oldfiles<cr>', desc = 'Recent Files' },
  { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Files' },
  { '<leader>fs', '<cmd>Telescope live_grep<cr>', desc = 'Strings' },
  { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
  { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help' },
  { '<leader>fm', '<cmd>Telescope file_browser<cr>', desc = 'File Browser' },

  -- Harpoon
  { '<leader>h', group = 'Harpoon' },
  { '<leader>ha', function() require('harpoon'):list():add() end, desc = 'Add File' },
  { '<leader>hm', function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end, desc = 'Menu' },
  { '<leader>hn', function() require('harpoon'):list():next() end, desc = 'Next' },
  { '<leader>hp', function() require('harpoon'):list():prev() end, desc = 'Previous' },

  -- Agents
  { '<leader>o', group = 'Agents' },
  { '<leader>oo', function() require('opencode.api').open_input() end, desc = 'OpenCode' },
  { '<leader>oi', function() require('opencode.api').open_input() end, desc = 'OpenCode Input' },
  { '<leader>ot', function() require('opencode.api').toggle_focus() end, desc = 'OpenCode Toggle Focus' },
  { '<leader>oc', '<cmd>ClaudeCodeFocus<cr>', desc = 'Claude Code' },
  { '<leader>n', group = 'Navigate' },
  { '<leader>nv', require('user.agents').open_claude_reference_under_cursor, desc = 'Open file under cursor' },
  { '<leader>np', require('user.agents').open_claude_prompt_scratch, desc = 'Claude prompt scratch' },

  -- Trouble
  { '<leader>t', group = 'Trouble' },
  { '<leader>tt', '<cmd>TroubleToggle<cr>', desc = 'Toggle' },
  { '<leader>tr', '<cmd>Trouble lsp_references<cr>', desc = 'References' },
  { '<leader>tD', '<cmd>Trouble lsp_definitions<cr>', desc = 'Definitions' },
  { '<leader>td', '<cmd>Trouble document_diagnostics<cr>', desc = 'Diagnostics' },
  { '<leader>tq', '<cmd>Trouble quickfix<cr>', desc = 'QuickFix' },
  { '<leader>tl', '<cmd>Trouble loclist<cr>', desc = 'LocationList' },
  { '<leader>tw', '<cmd>Trouble workspace_diagnostics<cr>', desc = 'Workspace Diagnostics' },

  -- Window
  { '<leader>w', group = 'Window' },
  { '<leader>wc', '<c-w>c', desc = 'Close' },
  { '<leader>wn', '<c-w>h', desc = 'Left' },
  { '<leader>we', '<c-w>j', desc = 'Down' },
  { '<leader>wi', '<c-w>k', desc = 'Up' },
  { '<leader>wo', '<c-w>l', desc = 'Right' },
  { '<leader>wv', '<cmd>vsp<cr>', desc = 'Vertical Split' },
  { '<leader>wh', '<cmd>sp<cr>', desc = 'Horizontal Split' },

  -- Session
  { '<leader>q', group = 'Session' },
  { '<leader>qs', [[<cmd>lua require("persistence").load()<cr>]], desc = 'Restore Current Dir Session' },
  { '<leader>ql', [[<cmd>lua require("persistence").load({ last = true })<cr>]], desc = 'Restore Last Session' },
  { '<leader>qd', [[<cmd>lua require("persistence").stop()<cr>]], desc = 'Exit Current Session' },
})
