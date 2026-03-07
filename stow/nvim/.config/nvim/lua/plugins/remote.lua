return {
  'chipsenkbeil/distant.nvim',
  branch = 'v0.3',
  config = function()
    require('distant'):setup({
      manager = {
        user = true,
      },
    })

    -- distant.nvim hardcodes border styles; patch them to rounded
    for _, name in ipairs({ 'distant.ui.windows.main', 'distant.ui.windows.metadata' }) do
      local win = require(name)
      local opts = win:winopts()
      opts.border = 'rounded'
      win:set_winopts(opts)
    end
  end,
  keys = {
    {
      '<leader>rc',
      function()
        vim.ui.input({ prompt = 'DistantConnect ssh://user@host: ssh://' }, function(dest)
          if dest and dest ~= '' and dest ~= 'ssh://' then
            vim.cmd('DistantConnect ' .. dest)
          end
        end)
      end,
      desc = 'Remote connect',
    },
    { '<leader>ro', '<cmd>DistantOpen<cr>', desc = 'Remote open file' },
    {
      '<leader>rl',
      function()
        vim.ui.input({ prompt = 'DistantLaunch ssh://user@host: ssh://' }, function(dest)
          if dest and dest ~= '' and dest ~= 'ssh://' then
            vim.cmd('DistantLaunch ' .. dest)
          end
        end)
      end,
      desc = 'Remote launch server',
    },
    { '<leader>re', '<cmd>DistantShell<cr>',              desc = 'Remote shell' },
    { '<leader>rf', '<cmd>DistantSearch<cr>',            desc = 'Remote find/grep' },
    { '<leader>r!', '<cmd>DistantSpawn<cr>',             desc = 'Remote run command' },
    { '<leader>rs', '<cmd>DistantSessionInfo<cr>',     desc = 'Remote session info' },
    { '<leader>rI', '<cmd>DistantInstall<cr>',         desc = 'Remote install local CLI' },
    {
      '<leader>ri',
      function()
        vim.ui.input({ prompt = 'distant-install user@host: ' }, function(host)
          if host and host ~= '' then
            vim.cmd('split | terminal ' .. vim.o.shell .. ' -ic "distant-install ' .. host .. '"')
          end
        end)
      end,
      desc = 'Remote install distant server',
    },
  },
}
