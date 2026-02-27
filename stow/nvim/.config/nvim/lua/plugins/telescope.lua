return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>?', function() require('telescope.builtin').oldfiles() end, desc = '[?] Find recently opened files' },
      { '<leader><space>', function() require('telescope.builtin').buffers() end, desc = '[ ] Find existing buffers' },
      { '<leader>/', function() require('telescope.builtin').current_buffer_fuzzy_find() end, desc = '[/] Fuzzily search in current buffer' },
      { '<leader>sf', function() require('telescope.builtin').find_files() end, desc = '[S]earch [F]iles' },
      { '<leader>sh', function() require('telescope.builtin').help_tags() end, desc = '[S]earch [H]elp' },
      { '<leader>sw', function() require('telescope.builtin').grep_string() end, desc = '[S]earch current [W]ord' },
      { '<leader>sg', function() require('telescope.builtin').live_grep() end, desc = '[S]earch by [G]rep' },
      { '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = '[S]earch [D]iagnostics' },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
          },
        },
      },
    },
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function() return vim.fn.executable('make') == 1 end,
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('telescope').load_extension('fzf')
    end,
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>b', function() require('telescope').extensions.file_browser.file_browser() end, desc = 'Toggle File [B]rowser' },
    },
    config = function()
      require('telescope').setup({
        extensions = {
          file_browser = {
            hijack_netrw = true,
            hidden = true,
            respect_gitignore = false,
          },
        },
      })
      require('telescope').load_extension('file_browser')
    end,
    init = function()
      vim.g.loaded_netrwPlugin = 1
      vim.g.loaded_netrw = 1
      vim.api.nvim_create_autocmd('BufEnter', {
        callback = function(args)
          local path = vim.api.nvim_buf_get_name(args.buf)
          if path ~= '' and vim.fn.isdirectory(path) == 1 then
            vim.schedule(function()
              vim.cmd('bdelete ' .. args.buf)
              require('telescope').extensions.file_browser.file_browser({ path = path })
            end)
          end
        end,
      })
    end,
  },
}
