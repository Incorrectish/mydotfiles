-- Leader key (must be set before plugins)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require 'user.plugins'

-- Load configuration modules
require 'user.options'
require 'user.telescope'
require 'user.treesitter'
require 'user.lsp'
require 'user.completion'
require 'user.keymaps'
require 'user.dashboard'
require 'user.lualine'
require 'user.nvim-tree'
require 'user.leap'
require 'user.harpoon'

-- Colorscheme
vim.cmd.colorscheme 'incorrectish_colors'

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

-- Disable formatexpr for certain filetypes (so gq works)
vim.api.nvim_create_augroup('RemoveConformFormatExpr', { clear = true })
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = 'RemoveConformFormatExpr',
  pattern = { '*.txt', '*.org', '*.md' },
  callback = function() vim.opt_local.formatexpr = '' end,
})
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = 'RemoveConformFormatExpr',
  pattern = '*',
  callback = function()
    if not vim.fn.expand('%:t'):find('%.') then
      vim.opt_local.formatexpr = ''
    end
  end,
})
