local M = {}

local function normalize_candidate(raw)
  if not raw or raw == '' then
    return nil, nil
  end

  local candidate = raw:gsub('^[`"\']+', ''):gsub('[`"\',:;]+$', '')
  local path, line = candidate:match('^(.-):(%d+)$')
  if path then
    return path, tonumber(line)
  end

  return candidate, nil
end

local function resolve_file(path)
  if not path or path == '' then
    return nil
  end

  if vim.fn.filereadable(path) == 1 then
    return vim.fn.fnamemodify(path, ':p')
  end

  local cwd_path = vim.fn.fnamemodify(path, ':p')
  if vim.fn.filereadable(cwd_path) == 1 then
    return cwd_path
  end

  return nil
end

local function open_in_previous_window(path, line)
  local previous = vim.fn.win_getid(vim.fn.winnr('#'))
  if previous == 0 or not vim.api.nvim_win_is_valid(previous) then
    vim.notify('No target editing window available', vim.log.levels.WARN)
    return
  end

  vim.api.nvim_set_current_win(previous)
  vim.cmd.edit(vim.fn.fnameescape(path))
  if line then
    vim.api.nvim_win_set_cursor(0, { line, 0 })
  end
end

function M.open_reference_under_cursor()
  local raw = vim.fn.expand('<cfile>')
  local path, line = normalize_candidate(raw)
  local resolved = resolve_file(path)

  if not resolved then
    vim.notify('No readable file found under cursor', vim.log.levels.WARN)
    return
  end

  open_in_previous_window(resolved, line)
end

function M.setup()
  local group = vim.api.nvim_create_augroup('UserAgentWindows', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'opencode_output',
    callback = function(args)
      vim.keymap.set('n', 'gd', M.open_reference_under_cursor, {
        buffer = args.buf,
        desc = 'Open file reference in code window',
      })
    end,
  })
end

return M
