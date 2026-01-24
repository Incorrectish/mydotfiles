-- Lualine configuration

require('lualine').setup {
  options = {
    icons_enabled = true,
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    globalstatus = false,
  },
  sections = {
    lualine_a = {
      {
        'mode',
        icon = '',
        separator = { left = '', right = '' },
        color = { fg = '#00ffe9', bg = '#7d83ac' },
      },
    },
    lualine_b = {
      {
        'branch',
        icon = '',
        separator = { left = '', right = '' },
        color = { fg = 'ff0030', bg = '#333333' },
      },
      {
        'diff',
        separator = { left = '', right = '' },
        color = { fg = '#1c1d21', bg = '#7d83ac' },
      },
    },
    lualine_c = {
      {
        'diagnostics',
        separator = { left = '', right = '' },
        color = { bg = '#7d83ac' },
      },
      {
        'filename',
        color = { bg = '#222222' },
      },
    },
    lualine_y = {
      {
        'filetype',
        icons_enabled = false,
        color = { fg = '#ff008f', bg = '#000000' },
      },
    },
    lualine_z = {
      {
        'location',
        icon = '',
        color = { fg = '#6800ff', bg = '#111111' },
      },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  extensions = { 'neo-tree', 'lazy' },
}
