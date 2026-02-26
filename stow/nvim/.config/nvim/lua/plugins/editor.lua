local using_vscode = vim.g.vscode ~= nil

return {
  { 'numToStr/Comment.nvim', opts = {} },
  'tpope/vim-sleuth',
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    cond = not using_vscode,
    opts = {
      indent = {
        char = '│',
      },
    },
  },
  {
    url = 'https://codeberg.org/andyg/leap.nvim',
    dependencies = { 'tpope/vim-repeat' },
    keys = {
      { 's', '<Plug>(leap)', mode = { 'n', 'x', 'o' }, desc = 'Leap' },
      { 'gs', '<Plug>(leap-from-window)', mode = { 'n', 'x', 'o' }, desc = 'Leap from window' },
    },
  },
  'danilamihailov/beacon.nvim',
  { 'lukas-reineke/virt-column.nvim', opts = {} },
}
