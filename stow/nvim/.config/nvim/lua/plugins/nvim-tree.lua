return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  keys = {
    { '<leader>b', '<cmd>Neotree toggle<cr>', desc = 'Toggle File [B]rowser' },
  },
  opts = {
    window = {
      position = 'float',
      popup = {
        size = { height = '80%', width = '50%' },
        position = '50%',
        border = 'rounded',
      },
    },
    filesystem = {
      hijack_netrw_behavior = 'open_default',
    },
  },
}
