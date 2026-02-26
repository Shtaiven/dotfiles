local using_vscode = vim.g.vscode ~= nil

return {
  {
    'nvim-lualine/lualine.nvim',
    cond = not using_vscode,
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'gruvbox-material',
          globalstatus = true,
          component_separators = '',
          section_separators = { left = '▓▒░', right = '░▒▓' },
        },
        sections = {
          lualine_a = {
            { 'mode', separator = { left = '', right = '▓▒░' } },
          },
          lualine_z = {
            { 'location', separator = { left = '░▒▓', right = '' } },
          },
        },
        tabline = {
          lualine_a = {
            {
              'buffers',
              separator = { left = '', right = '▓▒░' },
              draw_empty = true,
              buffers_color = {
                active = (function()
                  local c = vim.fn['gruvbox_material#get_configuration']()
                  local p = vim.fn['gruvbox_material#get_palette'](c.background, c.foreground, c.colors_override)
                  return { fg = p.bg0[1], bg = p.blue[1], gui = 'bold' }
                end)(),
                inactive = (function()
                  local c = vim.fn['gruvbox_material#get_configuration']()
                  local p = vim.fn['gruvbox_material#get_palette'](c.background, c.foreground, c.colors_override)
                  return { fg = p.bg0[1], bg = p.grey2[1] }
                end)(),
              },
              symbols = { alternate_file = '' },
            },
          },
          lualine_z = {
            { 'tabs', separator = { left = '░▒▓', right = '' } },
          },
        },
        extensions = {
          'fugitive',
          'fzf',
          'nvim-tree',
          'toggleterm',
        },
      }
    end,
  },
  {
    'brenoprata10/nvim-highlight-colors',
    opts = {
      render = 'background',
      enable_named_colors = true,
      enable_tailwind = true,
    },
  },
}
