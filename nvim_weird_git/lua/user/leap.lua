require('leap').create_default_mappings()
vim.cmd [[autocmd ColorScheme * lua require('leap').init_highlight(true)]]
require('leap').opts.special_keys.prev_target = '<bs>'
require('leap').opts.special_keys.prev_group = '<bs>'
require('leap.user').set_repeat_keys('<cr>', '<bs>')

local api = vim.api
local ts = vim.treesitter

local function get_ts_nodes()
  if not pcall(ts.get_parser) then return end
  local wininfo = vim.fn.getwininfo(api.nvim_get_current_win())[1]
  -- Get current node, and then its parent nodes recursively.
  local cur_node = ts.get_node()
  if not cur_node then return end
  local nodes = { cur_node }
  local parent = cur_node:parent()
  while parent do
    table.insert(nodes, parent)
    parent = parent:parent()
  end
  -- Create Leap targets from TS nodes.
  local targets = {}
  local startline, startcol
  for _, node in ipairs(nodes) do
    startline, startcol, endline, endcol = node:range()  -- (0,0)
    local startpos = { startline + 1, startcol + 1 }
    local endpos = { endline + 1, endcol + 1 }
    -- Add both ends of the node.
    if startline + 1 >= wininfo.topline then
      table.insert(targets, { pos = startpos, altpos = endpos })
    end
    if endline + 1 <= wininfo.botline then
      table.insert(targets, { pos = endpos, altpos = startpos })
    end
  end
  if #targets >= 1 then return targets end
end

local function select_node_range(target)
  local mode = api.nvim_get_mode().mode
  -- Force going back to Normal from Visual mode.
  if not mode:match('no?') then vim.cmd('normal! ' .. mode) end
  vim.fn.cursor(unpack(target.pos))
  local v = mode:match('V') and 'V' or mode:match('�') and '�' or 'v'
  vim.cmd('normal! ' .. v)
  vim.fn.cursor(unpack(target.altpos))
end

local function leap_ts()
  require('leap').leap {
    target_windows = { api.nvim_get_current_win() },
    targets = get_ts_nodes,
    action = select_node_range,
  }
end

vim.keymap.set({'x', 'o'}, '\\', leap_ts)
