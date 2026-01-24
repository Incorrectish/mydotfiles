-- nvim-tree configuration

require('nvim-tree').setup {
  disable_netrw = true,
  hijack_netrw = true,
  on_attach = 'default',
  view = {
    width = 30,
    side = 'left',
  },
  renderer = {
    icons = {
      glyphs = {
        default = 'F',
        symlink = 'S',
        bookmark = 'B',
        folder = {
          arrow_closed = '⮞',
          arrow_open = '⮟',
        },
      },
    },
  },
}
