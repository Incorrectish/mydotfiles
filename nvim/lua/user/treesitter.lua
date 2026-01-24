-- Treesitter and textobjects configuration

vim.defer_fn(function()
  require('nvim-treesitter').setup {
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },
    auto_install = false,
    sync_install = false,
    ignore_install = {},
  }

  require('nvim-treesitter-textobjects').setup {
    select = { lookahead = true },
    move = { set_jumps = true },
  }

  -- Textobject select keymaps
  local select = require('nvim-treesitter-textobjects.select').select_textobject
  vim.keymap.set({ 'x', 'o' }, 'aa', function() select('@parameter.outer', 'textobjects') end, { desc = 'Select outer parameter' })
  vim.keymap.set({ 'x', 'o' }, 'ia', function() select('@parameter.inner', 'textobjects') end, { desc = 'Select inner parameter' })
  vim.keymap.set({ 'x', 'o' }, 'af', function() select('@function.outer', 'textobjects') end, { desc = 'Select outer function' })
  vim.keymap.set({ 'x', 'o' }, 'if', function() select('@function.inner', 'textobjects') end, { desc = 'Select inner function' })
  vim.keymap.set({ 'x', 'o' }, 'ac', function() select('@class.outer', 'textobjects') end, { desc = 'Select outer class' })
  vim.keymap.set({ 'x', 'o' }, 'ic', function() select('@class.inner', 'textobjects') end, { desc = 'Select inner class' })

  -- Textobject move keymaps
  local move = require('nvim-treesitter-textobjects.move')
  vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() move.goto_next_start('@function.outer', 'textobjects') end, { desc = 'Next function start' })
  vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() move.goto_next_start('@class.outer', 'textobjects') end, { desc = 'Next class start' })
  vim.keymap.set({ 'n', 'x', 'o' }, ']M', function() move.goto_next_end('@function.outer', 'textobjects') end, { desc = 'Next function end' })
  vim.keymap.set({ 'n', 'x', 'o' }, '][', function() move.goto_next_end('@class.outer', 'textobjects') end, { desc = 'Next class end' })
  vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() move.goto_previous_start('@function.outer', 'textobjects') end, { desc = 'Previous function start' })
  vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() move.goto_previous_start('@class.outer', 'textobjects') end, { desc = 'Previous class start' })
  vim.keymap.set({ 'n', 'x', 'o' }, '[M', function() move.goto_previous_end('@function.outer', 'textobjects') end, { desc = 'Previous function end' })
  vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() move.goto_previous_end('@class.outer', 'textobjects') end, { desc = 'Previous class end' })

  -- Textobject swap keymaps
  local swap = require('nvim-treesitter-textobjects.swap')
  vim.keymap.set('n', '<leader>a', function() swap.swap_next('@parameter.inner') end, { desc = 'Swap with next parameter' })
  vim.keymap.set('n', '<leader>A', function() swap.swap_previous('@parameter.inner') end, { desc = 'Swap with previous parameter' })
end, 0)
