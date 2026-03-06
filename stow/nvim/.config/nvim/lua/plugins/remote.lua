return {
  'chipsenkbeil/distant.nvim',
  branch = 'v0.3',
  config = function()
    require('distant'):setup()
  end,
  keys = {
    { '<leader>rc', '<cmd>DistantConnect<cr>',    desc = 'Remote connect' },
    { '<leader>ro', '<cmd>DistantOpen<cr>',        desc = 'Remote open file' },
    { '<leader>rl', '<cmd>DistantLaunch<cr>',      desc = 'Remote launch server' },
    { '<leader>rs', '<cmd>DistantSessionInfo<cr>', desc = 'Remote session info' },
  },
}
