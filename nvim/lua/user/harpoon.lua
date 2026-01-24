-- Harpoon configuration

local harpoon = require('harpoon')
harpoon:setup()

-- Telescope integration
local conf = require('telescope.config').values
local function toggle_telescope(harpoon_files)
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end
  require('telescope.pickers').new({}, {
    prompt_title = 'Harpoon',
    finder = require('telescope.finders').new_table { results = file_paths },
    previewer = conf.file_previewer({}),
    sorter = conf.generic_sorter({}),
  }):find()
end

-- Keymaps
vim.keymap.set('n', '<C-J>', function() harpoon:list():next() end)
vim.keymap.set('n', '<C-K>', function() harpoon:list():prev() end)
vim.keymap.set('n', '<C-1>', function() harpoon:list():select(1) end)
vim.keymap.set('n', '<C-2>', function() harpoon:list():select(2) end)
vim.keymap.set('n', '<C-3>', function() harpoon:list():select(3) end)
vim.keymap.set('n', '<C-4>', function() harpoon:list():select(4) end)
vim.keymap.set('n', '<C-5>', function() harpoon:list():select(5) end)
