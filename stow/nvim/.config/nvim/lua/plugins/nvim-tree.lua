return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  keys = {
    { '<leader>b', function() require('nvim-tree.api').tree.toggle() end, desc = 'Toggle File [B]rowser' },
  },
  opts = {},
}
