local M = {}

local ns = vim.api.nvim_create_namespace('user_pr_review_notes')
local sign_name = 'UserPrReviewNote'
local notes = {}
local scratch_bufnr = nil
local rendering_scratch = false
local next_note_id = 1

vim.fn.sign_define(sign_name, {
  text = '!',
  texthl = 'DiagnosticWarn',
  numhl = 'DiagnosticWarn',
})

local function note_key(bufnr, start_line, end_line)
  return tostring(bufnr) .. ':' .. tostring(start_line) .. ':' .. tostring(end_line)
end

local function allocate_note_id()
  local id = next_note_id
  next_note_id = next_note_id + 1
  return id
end

local function clear_note_marks(note)
  if note.sign_ids then
    for _, sign_id in ipairs(note.sign_ids) do
      pcall(vim.fn.sign_unplace, 'user_pr_review_notes', {
        buffer = note.bufnr,
        id = sign_id,
      })
    end
  elseif note.sign_id then
    pcall(vim.fn.sign_unplace, 'user_pr_review_notes', {
      buffer = note.bufnr,
      id = note.sign_id,
    })
  end

  if note.extmark_ids then
    for _, extmark_id in ipairs(note.extmark_ids) do
      pcall(vim.api.nvim_buf_del_extmark, note.bufnr, ns, extmark_id)
    end
  elseif note.extmark_id then
    pcall(vim.api.nvim_buf_del_extmark, note.bufnr, ns, note.extmark_id)
  end

  note.sign_ids = {}
  note.extmark_ids = {}
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
    table.insert(lines, string.format('- [%d] %s', note.id, location))
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

  rendering_scratch = true
  vim.bo[scratch_bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(scratch_bufnr, 0, -1, false, render_lines())
  vim.bo[scratch_bufnr].modified = false
  rendering_scratch = false
end

local function put_note_mark(note)
  clear_note_marks(note)

  local line_count = vim.api.nvim_buf_line_count(note.bufnr)
  local start_line = math.min(math.max(note.start_line, 1), line_count)
  local end_line = math.min(math.max(note.end_line, 1), line_count)

  for line = start_line, end_line do
    local sign_id = note.bufnr * 100000 + line
    local extmark_id = vim.api.nvim_buf_set_extmark(note.bufnr, ns, line - 1, 0, {
      virt_text = { { line == start_line and ' PR note' or ' PR note range', 'DiagnosticWarn' } },
      virt_text_pos = 'eol',
      hl_mode = 'combine',
    })

    table.insert(note.sign_ids, sign_id)
    table.insert(note.extmark_ids, extmark_id)
    vim.fn.sign_place(sign_id, 'user_pr_review_notes', sign_name, note.bufnr, {
      lnum = line,
      priority = 20,
    })
  end
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

local function parse_location(location)
  local id, rest = location:match('^%[(%d+)%]%s+(.+)$')
  location = rest or location

  local path, start_line, end_line = location:match('^(.-):(%d+)%-(%d+)$')
  if path then
    return tonumber(id), path, tonumber(start_line), tonumber(end_line)
  end

  path, start_line = location:match('^(.-):(%d+)$')
  if path then
    return tonumber(id), path, tonumber(start_line), tonumber(start_line)
  end
end

local function parse_scratch_lines(lines)
  local parsed = {}
  local current = nil

  for _, line in ipairs(lines) do
    local location = line:match('^%-%s+(.+)$')
    if location then
      local id, path, start_line, end_line = parse_location(location)
      if path and start_line and end_line then
        current = {
          id = id,
          path = path,
          start_line = start_line,
          end_line = end_line,
          text_lines = {},
        }
        table.insert(parsed, current)
      else
        current = nil
      end
    elseif current then
      local text_line = line:match('^%s%s(.*)$')
      if text_line then
        table.insert(current.text_lines, text_line)
      elseif line ~= '' then
        table.insert(current.text_lines, line)
      end
    end
  end

  return parsed
end

local function find_note_buffer(path)
  for _, note in pairs(notes) do
    if note.path == path and vim.api.nvim_buf_is_valid(note.bufnr) then
      return note.bufnr
    end
  end

  local full_path = vim.fn.fnamemodify(path, ':p')
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_name(bufnr) == full_path then
      return bufnr
    end
  end
end

local function find_note_by_id(id)
  if not id then
    return nil
  end

  for key, note in pairs(notes) do
    if note.id == id then
      return key, note
    end
  end
end

local function apply_scratch_edits()
  if rendering_scratch or not scratch_bufnr or not vim.api.nvim_buf_is_valid(scratch_bufnr) then
    return
  end

  local parsed = parse_scratch_lines(vim.api.nvim_buf_get_lines(scratch_bufnr, 0, -1, false))
  local next_notes = {}

  for _, note in pairs(notes) do
    clear_note_marks(note)
  end

  for _, item in ipairs(parsed) do
    local _, existing_note = find_note_by_id(item.id)
    local bufnr = existing_note and existing_note.bufnr or find_note_buffer(item.path)
    if bufnr then
      local note = {
        id = item.id or allocate_note_id(),
        bufnr = bufnr,
        path = item.path,
        start_line = item.start_line,
        end_line = item.end_line,
        text = table.concat(item.text_lines, '\n'),
      }

      if note.text ~= '' then
        next_notes[note_key(bufnr, note.start_line, note.end_line)] = note
        put_note_mark(note)
      end
    end
  end

  notes = next_notes
  refresh_scratch()
end

function M.add(start_line, end_line)
  local bufnr = vim.api.nvim_get_current_buf()

  if not start_line or not end_line then
    start_line = current_line()
    end_line = start_line
  end

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  start_line = math.min(math.max(start_line, 1), line_count)
  end_line = math.min(math.max(end_line, 1), line_count)

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
      id = allocate_note_id(),
      bufnr = bufnr,
      path = path,
      start_line = start_line,
      end_line = end_line,
      sign_ids = {},
      extmark_ids = {},
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

  clear_note_marks(note)
  notes[key] = nil
  refresh_scratch()
end

function M.open()
  if not scratch_bufnr or not vim.api.nvim_buf_is_valid(scratch_bufnr) then
    scratch_bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[scratch_bufnr].buftype = 'acwrite'
    vim.bo[scratch_bufnr].bufhidden = 'hide'
    vim.bo[scratch_bufnr].filetype = 'markdown'
    vim.api.nvim_buf_set_name(scratch_bufnr, 'Local PR Review Notes')
    vim.api.nvim_create_autocmd('BufWriteCmd', {
      buffer = scratch_bufnr,
      callback = function(args)
        apply_scratch_edits()
        vim.bo[args.buf].modified = false
        vim.notify('Local PR review notes updated')
      end,
    })
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
    clear_note_marks(note)
    notes[key] = nil
  end
  refresh_scratch()
end

return M
