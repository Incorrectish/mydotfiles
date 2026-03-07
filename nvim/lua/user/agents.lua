local M = {}

local function is_agent_buffer(buf)
  local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
  return ft == 'opencode' or ft == 'opencode_output'
end

local function is_editable_code_window(win)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return false
  end

  local cfg = vim.api.nvim_win_get_config(win)
  if cfg.relative and cfg.relative ~= '' then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local bt = vim.api.nvim_get_option_value('buftype', { buf = buf })
  return not is_agent_buffer(buf) and bt == ''
end

local function find_left_code_window()
  local left = vim.fn.win_getid(vim.fn.winnr('h'))
  if is_editable_code_window(left) then
    return left
  end
end

local function find_code_window()
  local left = find_left_code_window()
  if left then
    return left
  end

  local ok, state = pcall(require, 'opencode.state')
  if ok then
    local last = state.last_code_win_before_opencode
    if is_editable_code_window(last) then
      return last
    end
  end

  local current_tab = vim.api.nvim_get_current_tabpage()
  local wins = vim.api.nvim_tabpage_list_wins(current_tab)

  for _, win in ipairs(wins) do
    if is_editable_code_window(win) then
      return win
    end
  end
end

local function open_in_code_window(path, line)
  local target = find_code_window()
  if target and vim.api.nvim_win_is_valid(target) then
    vim.api.nvim_set_current_win(target)
  else
    vim.cmd('leftabove vsplit')
  end

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

local function normalize_path_reference(raw)
  if not raw or raw == '' then
    return nil, nil
  end

  local cleaned = raw
    :gsub("^[%s`\"'(<%[]+", '')
    :gsub("[%s`\"')>,;%]]+$", '')

  local path, line = cleaned:match('^(.-):(%d+)$')
  if not path then
    path = cleaned
  end

  local resolved = vim.fn.fnamemodify(path, ':p')
  if vim.fn.filereadable(resolved) ~= 1 then
    return nil, nil
  end

  return resolved, line and tonumber(line) or nil
end

function M.open_claude_reference_under_cursor()
  local resolved, line = normalize_path_reference(vim.fn.expand('<cWORD>'))
  if not resolved then
    vim.notify('No readable file path under cursor', vim.log.levels.WARN)
    return
  end

  open_in_code_window(resolved, line)
end

local function get_claude_terminal_buf()
  local ok, terminal = pcall(require, 'claudecode.terminal')
  if not ok or type(terminal.get_active_terminal_bufnr) ~= 'function' then
    return nil
  end

  local buf = terminal.get_active_terminal_bufnr()
  if buf and vim.api.nvim_buf_is_valid(buf) then
    return buf
  end
end

function M.is_current_claude_terminal()
  local term_buf = get_claude_terminal_buf()
  return term_buf ~= nil and vim.api.nvim_get_current_buf() == term_buf
end

local function send_to_claude_terminal(text)
  local term_buf = get_claude_terminal_buf()
  if not term_buf then
    vim.notify('Claude terminal is not available', vim.log.levels.WARN)
    return false
  end

  local job_id = vim.b[term_buf].terminal_job_id
  if not job_id then
    vim.notify('Claude terminal job is not available', vim.log.levels.WARN)
    return false
  end

  -- Use bracketed paste so multiline prompts are inserted cleanly without executing.
  vim.fn.chansend(job_id, '\27[200~' .. text .. '\27[201~')
  return true
end

local function focus_claude_terminal()
  local term_buf = get_claude_terminal_buf()
  if not term_buf then
    return
  end

  for _, win in ipairs(vim.fn.win_findbuf(term_buf)) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_set_current_win(win)
      vim.cmd('startinsert')
      return
    end
  end
end

local function submit_claude_prompt_buffer(buf, win)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local text = table.concat(lines, '\n')
  if vim.trim(text) == '' then
    vim.notify('Claude prompt is empty', vim.log.levels.WARN)
    return
  end

  if not send_to_claude_terminal(text) then
    return
  end

  vim.api.nvim_set_option_value('modified', false, { buf = buf })
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  focus_claude_terminal()
end

local mention_files_cache = nil

local function repo_files()
  if mention_files_cache then
    return mention_files_cache
  end

  local git_files = vim.fn.systemlist({ 'git', 'ls-files', '--cached', '--others', '--exclude-standard' })
  if vim.v.shell_error == 0 then
    mention_files_cache = git_files
    return mention_files_cache
  end

  local rg_files = vim.fn.systemlist({ 'rg', '--files' })
  if vim.v.shell_error == 0 then
    mention_files_cache = rg_files
    return mention_files_cache
  end

  mention_files_cache = {}
  return mention_files_cache
end

local function insert_text_at_cursor(win, buf, text, resume_insert)
  if not (win and vim.api.nvim_win_is_valid(win) and buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end

  vim.api.nvim_set_current_win(win)
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ''
  local max_col = #line
  local insert_col = resume_insert and (col + 1) or col
  insert_col = math.max(0, math.min(insert_col, max_col))
  vim.api.nvim_buf_set_text(buf, row - 1, insert_col, row - 1, insert_col, { text })
  if resume_insert then
    vim.cmd('startinsert')
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_cursor(win, { row, insert_col + #text })
      end
    end)
  else
    vim.api.nvim_win_set_cursor(win, { row, insert_col + #text })
  end
end

local function open_claude_mention_picker(win, buf, resume_insert)
  local ok, pickers = pcall(require, 'telescope.pickers')
  local ok_finders, finders = pcall(require, 'telescope.finders')
  local ok_config, telescope_config = pcall(require, 'telescope.config')
  local ok_actions, actions = pcall(require, 'telescope.actions')
  local ok_state, action_state = pcall(require, 'telescope.actions.state')

  if not (ok and ok_finders and ok_config and ok_actions and ok_state) then
    vim.notify('Telescope is required for Claude file mentions', vim.log.levels.WARN)
    return
  end

  pickers.new({}, {
    prompt_title = 'Claude Mention File',
    finder = finders.new_table {
      results = repo_files(),
    },
    sorter = telescope_config.values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection and selection[1] then
          vim.schedule(function()
            insert_text_at_cursor(win, buf, '@' .. selection[1], resume_insert)
          end)
        end
      end)
      return true
    end,
  }):find()
end

function M.open_claude_prompt_scratch()
  local current = vim.api.nvim_get_current_win()
  vim.cmd('botright 8new')
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_set_option_value('buftype', 'acwrite', { buf = buf })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
  vim.api.nvim_set_option_value('swapfile', false, { buf = buf })
  vim.api.nvim_set_option_value('buflisted', false, { buf = buf })
  vim.api.nvim_set_option_value('filetype', 'markdown', { buf = buf })
  vim.api.nvim_set_option_value('wrap', true, { win = win })
  vim.api.nvim_set_option_value('linebreak', true, { win = win })
  vim.api.nvim_set_option_value('breakindent', true, { win = win })
  vim.api.nvim_buf_set_name(buf, 'claude-prompt://scratch')

  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = buf,
    once = true,
    callback = function()
      submit_claude_prompt_buffer(buf, win)
    end,
  })
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
    if vim.api.nvim_win_is_valid(current) then
      vim.api.nvim_set_current_win(current)
    end
  end, { buffer = buf, silent = true, desc = 'Close Claude prompt scratch' })
  vim.keymap.set({ 'n', 'i' }, '<C-f>', function()
    open_claude_mention_picker(win, buf, vim.api.nvim_get_mode().mode:sub(1, 1) == 'i')
  end, {
    buffer = buf,
    silent = true,
    desc = 'Insert Claude file mention',
  })
  vim.keymap.set('i', '@', function()
    open_claude_mention_picker(win, buf, true)
  end, {
    buffer = buf,
    silent = true,
    desc = 'Insert Claude file mention',
  })
  vim.keymap.set('i', '<C-v>@', '@', {
    buffer = buf,
    silent = true,
    desc = 'Insert literal @',
  })

  vim.schedule(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_set_current_win(win)
      vim.cmd('startinsert')
    end
  end)
end

local function setup_claude_terminal_keymaps(buf)
  vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], {
    buffer = buf,
    silent = true,
    desc = 'Claude terminal normal mode',
  })
end

local function submit_opencode_prompt()
  require('opencode.api').submit_input_prompt()
end

function M.setup()
  local group = vim.api.nvim_create_augroup('UserAgentWindows', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'TermEnter' }, {
    group = group,
    callback = function(args)
      if M.is_current_claude_terminal() then
        setup_claude_terminal_keymaps(args.buf)
      end
    end,
  })

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
