local function git_root()
    local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    return root ~= "" and root or vim.fn.getcwd()
end

return {
    {
        "nvim-telescope/telescope.nvim",
        cond = not vim.g.vscode,
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            {
                "<leader><space>",
                function()
                    require("telescope.builtin").find_files({ cwd = git_root(), hidden = true })
                end,
                desc = "Find Files",
            },
            {
                "<leader>/",
                function()
                    require("telescope.builtin").current_buffer_fuzzy_find()
                end,
                desc = "[/] Fuzzily search in current buffer",
            },
            {
                "<leader>ff",
                function()
                    require("telescope.builtin").find_files({ cwd = git_root(), hidden = true })
                end,
                desc = "[F]ind [F]iles",
            },
            {
                "<leader>fF",
                function()
                    require("telescope.builtin").find_files({ cwd = "~", hidden = true })
                end,
                desc = "[F]ind [F]iles from home",
            },
            {
                "<leader>fr",
                function()
                    require("telescope.builtin").oldfiles()
                end,
                desc = "[F]ind [R]ecent files",
            },
            {
                "<leader>fb",
                function()
                    require("telescope.builtin").buffers()
                end,
                desc = "[F]ind [B]uffers",
            },
            {
                "<leader>fh",
                function()
                    require("telescope.builtin").help_tags()
                end,
                desc = "[F]ind [H]elp",
            },
            {
                "<leader>fw",
                function()
                    require("telescope.builtin").grep_string({ cwd = git_root() })
                end,
                desc = "[F]ind current [W]ord",
            },
            {
                "<leader>fg",
                function()
                    require("telescope.builtin").live_grep({ cwd = git_root() })
                end,
                desc = "[F]ind by [G]rep",
            },
            {
                "<leader>fd",
                function()
                    require("telescope.builtin").diagnostics()
                end,
                desc = "[F]ind [D]iagnostics",
            },
            {
                "<leader>fk",
                function()
                    require("telescope.builtin").keymaps()
                end,
                desc = "[F]ind [K]eymaps",
            },
            {
                "<leader>f:",
                function()
                    require("telescope.builtin").command_history()
                end,
                desc = "[F]ind command history",
            },
            {
                "<leader>f\"",
                function()
                    require("telescope.builtin").registers()
                end,
                desc = "[F]ind registers",
            },
            {
                "<leader>fp",
                function()
                    require("telescope.builtin").resume()
                end,
                desc = "[F]ind [P]revious (resume)",
            },
            {
                "<leader>gc",
                function()
                    require("telescope.builtin").git_commits()
                end,
                desc = "[G]it [C]ommits",
            },
            {
                "<leader>gS",
                function()
                    require("telescope.builtin").git_status()
                end,
                desc = "[G]it [S]tatus (telescope)",
            },
        },
        opts = {
            defaults = {
                mappings = {
                    i = {
                        ["<C-u>"] = false,
                        ["<C-d>"] = false,
                    },
                },
            },
        },
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        cond = function()
            return not vim.g.vscode and vim.fn.executable("make") == 1
        end,
        build = "make",
        dependencies = { "nvim-telescope/telescope.nvim" },
        config = function()
            require("telescope").load_extension("fzf")
        end,
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        cond = not vim.g.vscode,
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        keys = {
            {
                "<leader>fe",
                function()
                    require("telescope").extensions.file_browser.file_browser()
                end,
                desc = "[F]ile [E]xplorer",
            },
        },
        config = function()
            require("telescope").setup({
                extensions = {
                    file_browser = {
                        hijack_netrw = true,
                        hidden = true,
                        respect_gitignore = false,
                    },
                },
            })
            require("telescope").load_extension("file_browser")
        end,
        init = function()
            vim.g.loaded_netrwPlugin = 1
            vim.g.loaded_netrw = 1
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function(args)
                    local path = vim.api.nvim_buf_get_name(args.buf)
                    if path ~= "" and vim.fn.isdirectory(path) == 1 then
                        vim.schedule(function()
                            vim.cmd("bdelete " .. args.buf)
                            require("telescope").extensions.file_browser.file_browser({ path = path })
                        end)
                    end
                end,
            })
        end,
    },
}
