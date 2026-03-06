local M = {}

local source = {}
local cache = nil

local function repo_files()
  if cache then
    return cache
  end

  local git_files = vim.fn.systemlist({ 'git', 'ls-files', '--cached', '--others', '--exclude-standard' })
  if vim.v.shell_error == 0 then
    cache = git_files
    return cache
  end

  local rg_files = vim.fn.systemlist({ 'rg', '--files' })
  if vim.v.shell_error == 0 then
    cache = rg_files
    return cache
  end

  cache = {}
  return cache
end

local function mention_prefix()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before = line:sub(1, col)
  local prefix = before:match('@([^%s]*)$')
  return prefix
end

local function basename(path)
  return vim.fn.fnamemodify(path, ':t')
end

local function dirname(path)
  local dir = vim.fn.fnamemodify(path, ':h')
  return dir == '.' and '' or dir
end

function source.new()
  return setmetatable({}, { __index = source })
end

function source:get_trigger_characters()
  return { '@', '/' }
end

function source:get_keyword_pattern()
  return [[@\zs\f*]]
end

function source:get_keyword_length()
  return 0
end

function source:is_available()
  return vim.b.claude_prompt_scratch == true
end

function source:complete(_, callback)
  local prefix = mention_prefix()
  if prefix == nil then
    callback({ items = {}, isIncomplete = false })
    return
  end

  local prefix_matches = {}
  local basename_matches = {}
  for _, file in ipairs(repo_files()) do
    if prefix == '' or vim.startswith(file, prefix) then
      prefix_matches[#prefix_matches + 1] = {
        label = file,
        filterText = file,
        insertText = file,
        documentation = file,
      }
    elseif vim.startswith(basename(file), prefix) then
      local name = basename(file)
      local dir = dirname(file)
      basename_matches[#basename_matches + 1] = {
        label = dir ~= '' and (name .. '    ' .. dir) or name,
        filterText = basename(file),
        insertText = file,
        documentation = file,
      }
    end
  end

  local items = {}
  vim.list_extend(items, prefix_matches)
  vim.list_extend(items, basename_matches)

  callback({ items = items, isIncomplete = false })
end

function M.setup()
  local ok, cmp = pcall(require, 'cmp')
  if not ok then
    return
  end

  pcall(cmp.register_source, 'claude_mentions', source.new())
end

return M
