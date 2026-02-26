return {
  'akinsho/toggleterm.nvim',
  version = '*',
  keys = {
    { '<leader>j', desc = 'Toggle terminal' },
  },
  opts = {
    open_mapping = [[<leader>j]],
    insert_mappings = false,
    terminal_mappings = false,
  },
}
