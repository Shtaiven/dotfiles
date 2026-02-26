return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    spec = {
      { '<leader>s', group = 'Search' },
      { '<leader>d', group = 'Document' },
      { '<leader>w', group = 'Workspace' },
      { '<leader>c', group = 'Code' },
      { '<leader>r', group = 'Rename' },
    },
  },
}
