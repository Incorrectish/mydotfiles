local M = {}

local ns = vim.api.nvim_create_namespace('user_pr_review_notes')
local sign_name = 'UserPrReviewNote'
local notes = {}
local scratch_bufnr = nil

vim.fn.sign_define(sign_name, {
  text = '!',
  texthl = 'DiagnosticWarn',
  numhl = 'DiagnosticWarn',
})

local function note_key(bufnr, start_line, end_line)
  return tostring(bufnr) .. ':' .. tostring(start_line) .. ':' .. tostring(end_line)
end

local function buffer_path(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then
    return '[No Name]'
  end

  local cwd = vim.fn.getcwd()
  if vim.startswith(name, cwd .. '/') then
    return name:sub(#cwd + 2)
  end

  return name
end

local function sorted_notes()
  local items = {}
  for _, note in pairs(notes) do
    if vim.api.nvim_buf_is_valid(note.bufnr) then
      table.insert(items, note)
    end
  end

  table.sort(items, function(a, b)
    if a.path == b.path then
      return a.start_line < b.start_line
    end
    return a.path < b.path
  end)

  return items
end

local function render_lines()
  local lines = {
    '# Local PR Review Notes',
    '',
    'These notes are local to this Neovim session. They are not posted to GitHub.',
    '',
  }

  local items = sorted_notes()
  if #items == 0 then
    table.insert(lines, 'No notes.')
    return lines
  end

  for _, note in ipairs(items) do
    local location = note.start_line == note.end_line
        and string.format('%s:%d', note.path, note.start_line)
        or string.format('%s:%d-%d', note.path, note.start_line, note.end_line)
    table.insert(lines, '- ' .. location)
    for line in note.text:gmatch('[^\n]+') do
      table.insert(lines, '  ' .. line)
    end
    table.insert(lines, '')
  end

  return lines
end

local function refresh_scratch()
  if not scratch_bufnr or not vim.api.nvim_buf_is_valid(scratch_bufnr) then
    return
  end

  vim.bo[scratch_bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(scratch_bufnr, 0, -1, false, render_lines())
  vim.bo[scratch_bufnr].modifiable = false
end

local function put_note_mark(note)
  pcall(vim.fn.sign_unplace, 'user_pr_review_notes', {
    buffer = note.bufnr,
    id = note.sign_id,
  })

  pcall(vim.api.nvim_buf_del_extmark, note.bufnr, ns, note.extmark_id)

  note.sign_id = note.bufnr * 100000 + note.start_line
  note.extmark_id = vim.api.nvim_buf_set_extmark(note.bufnr, ns, note.start_line - 1, 0, {
    virt_text = { { ' PR note', 'DiagnosticWarn' } },
    virt_text_pos = 'eol',
    hl_mode = 'combine',
  })

  vim.fn.sign_place(note.sign_id, 'user_pr_review_notes', sign_name, note.bufnr, {
    lnum = note.start_line,
    priority = 20,
  })
end

local function visual_range()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  return start_line, end_line
end

local function current_line()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  return math.min(math.max(line, 1), vim.api.nvim_buf_line_count(bufnr))
end

local function note_at(bufnr, line)
  for key, note in pairs(notes) do
    if note.bufnr == bufnr and line >= note.start_line and line <= note.end_line then
      return key, note
    end
  end
end

function M.add()
  local bufnr = vim.api.nvim_get_current_buf()
  local mode = vim.fn.mode()
  local start_line, end_line

  if mode == 'v' or mode == 'V' or mode == '\22' then
    start_line, end_line = visual_range()
  else
    start_line = current_line()
    end_line = start_line
  end

  local path = buffer_path(bufnr)
  local existing = notes[note_key(bufnr, start_line, end_line)]
  local location = start_line == end_line
      and string.format('%s:%d', path, start_line)
      or string.format('%s:%d-%d', path, start_line, end_line)

  vim.ui.input({
    prompt = 'Local PR note ' .. location .. ': ',
    default = existing and existing.text or '',
  }, function(text)
    if not text or text == '' then
      return
    end

    local note = existing or {
      bufnr = bufnr,
      path = path,
      start_line = start_line,
      end_line = end_line,
    }
    note.text = text
    notes[note_key(bufnr, start_line, end_line)] = note
    put_note_mark(note)
    refresh_scratch()
  end)
end

function M.delete()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = current_line()
  local key, note = note_at(bufnr, line)

  if not note then
    vim.notify('No local PR note on this line', vim.log.levels.INFO)
    return
  end

  pcall(vim.fn.sign_unplace, 'user_pr_review_notes', {
    buffer = note.bufnr,
    id = note.sign_id,
  })
  pcall(vim.api.nvim_buf_del_extmark, note.bufnr, ns, note.extmark_id)
  notes[key] = nil
  refresh_scratch()
end

function M.open()
  if not scratch_bufnr or not vim.api.nvim_buf_is_valid(scratch_bufnr) then
    scratch_bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[scratch_bufnr].buftype = 'nofile'
    vim.bo[scratch_bufnr].bufhidden = 'hide'
    vim.bo[scratch_bufnr].filetype = 'markdown'
    vim.api.nvim_buf_set_name(scratch_bufnr, 'Local PR Review Notes')
  end

  refresh_scratch()
  vim.cmd('botright 12split')
  vim.api.nvim_win_set_buf(0, scratch_bufnr)
end

function M.yank()
  local lines = render_lines()
  local text = table.concat(lines, '\n')
  vim.fn.setreg('+', text)
  vim.fn.setreg('"', text)
  vim.notify('Local PR review notes yanked')
end

function M.clear()
  for key, note in pairs(notes) do
    pcall(vim.fn.sign_unplace, 'user_pr_review_notes', {
      buffer = note.bufnr,
      id = note.sign_id,
    })
    pcall(vim.api.nvim_buf_del_extmark, note.bufnr, ns, note.extmark_id)
    notes[key] = nil
  end
  refresh_scratch()
end

return M
