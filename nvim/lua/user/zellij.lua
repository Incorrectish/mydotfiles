local M = {}

local directions = {
  n = { vim = 'h', zellij = 'left' },
  e = { vim = 'j', zellij = 'down' },
  i = { vim = 'k', zellij = 'up' },
  o = { vim = 'l', zellij = 'right' },
}

local move_directions = {
  N = 'H',
  E = 'J',
  I = 'K',
  O = 'L',
}

function M.is_active()
  return vim.env.ZELLIJ ~= nil and vim.env.ZELLIJ ~= '' and vim.fn.executable('zellij') == 1
end

local function leave_special_mode_then(fn)
  local mode = vim.api.nvim_get_mode().mode

  if mode:sub(1, 1) == 't' then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 'n', false)
    vim.schedule(fn)
    return
  end

  if mode:sub(1, 1) == 'i' then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    vim.schedule(fn)
    return
  end

  fn()
end

local function move_focus_in_zellij(direction)
  vim.fn.system({ 'zellij', 'action', 'move-focus', direction })
end

function M.focus(key)
  local target = directions[key]
  if not target then
    return
  end

  local current = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(target.vim)
  if vim.api.nvim_get_current_win() ~= current then
    return
  end

  if M.is_active() then
    move_focus_in_zellij(target.zellij)
  end
end

function M.move_split(key)
  local target = move_directions[key]
  if not target then
    return
  end

  vim.cmd.wincmd(target)
end

function M.focus_any(key)
  leave_special_mode_then(function()
    M.focus(key)
  end)
end

function M.move_split_any(key)
  leave_special_mode_then(function()
    M.move_split(key)
  end)
end

function M.create_split(direction)
  leave_special_mode_then(function()
    if direction == 'horizontal' then
      vim.cmd.split()
    elseif direction == 'vertical' then
      vim.cmd.vsplit()
    end
  end)
end

return M
