local M = {}

local function is_agent_buffer(buf)
  local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
  return ft == 'opencode' or ft == 'opencode_output'
end

local function find_code_window()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local wins = vim.api.nvim_tabpage_list_wins(current_tab)

  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local bt = vim.api.nvim_get_option_value('buftype', { buf = buf })
    if not is_agent_buffer(buf) and bt == '' then
      return win
    end
  end
end

local function open_in_code_window(path, line)
  local target = find_code_window()
  if not target or not vim.api.nvim_win_is_valid(target) then
    vim.notify('No target editing window available', vim.log.levels.WARN)
    return
  end

  vim.api.nvim_set_current_win(target)
  vim.cmd.edit(vim.fn.fnameescape(path))
  if line then
    vim.api.nvim_win_set_cursor(0, { line, 0 })
  end
end

local function open_opencode_reference_under_cursor()
  local picker = require('opencode.ui.reference_picker')
  local line = vim.api.nvim_get_current_line()
  local references = picker.parse_references(line, '')

  if #references == 0 then
    vim.notify('No OpenCode file reference found on this line', vim.log.levels.WARN)
    return
  end

  local ref = references[1]
  local resolved = vim.fn.fnamemodify(ref.file_path, ':p')
  open_in_code_window(resolved, ref.line)
end

local function submit_opencode_prompt()
  require('opencode.api').submit_input_prompt()
end

function M.setup()
  local group = vim.api.nvim_create_augroup('UserAgentWindows', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'opencode',
    callback = function(args)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
            pcall(vim.api.nvim_set_option_value, 'wrap', true, { win = win })
            pcall(vim.api.nvim_set_option_value, 'linebreak', true, { win = win })
            pcall(vim.api.nvim_set_option_value, 'breakindent', true, { win = win })
          end
        end
      end)
      vim.keymap.set({ 'n', 'i' }, '<C-j>', submit_opencode_prompt, {
        buffer = args.buf,
        desc = 'Submit OpenCode prompt',
        silent = true,
      })
      vim.keymap.set({ 'n', 'i' }, '<C-s>', submit_opencode_prompt, {
        buffer = args.buf,
        desc = 'Submit OpenCode prompt',
        silent = true,
      })
    end,
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'opencode_output',
    callback = function(args)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
            pcall(vim.api.nvim_set_option_value, 'number', true, { win = win })
            pcall(vim.api.nvim_set_option_value, 'relativenumber', true, { win = win })
          end
        end
      end)
      vim.keymap.set('n', 'i', function() require('opencode.api').toggle_focus() end, {
        buffer = args.buf,
        desc = 'Focus OpenCode input',
        silent = true,
      })
      vim.keymap.set('n', 'gd', open_opencode_reference_under_cursor, {
        buffer = args.buf,
        desc = 'Open file reference in code window',
      })
      vim.keymap.set('n', 'gr', function() require('opencode.api').references() end, {
        buffer = args.buf,
        desc = 'Browse OpenCode references',
      })
    end,
  })
end

return M
