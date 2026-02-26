return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = { 'MunifTanjim/nui.nvim' },
  opts = {
    cmdline = {
      view = 'cmdline_popup',
      format = {
        cmdline = { icon = '>' },
        search_down = { icon = '/' },
        search_up = { icon = '?' },
      },
    },
    popupmenu = { enabled = true },
    lsp = {
      progress = { enabled = false }, -- fidget handles this
      signature = { enabled = false },
    },
    messages = { enabled = true },
  },
}
