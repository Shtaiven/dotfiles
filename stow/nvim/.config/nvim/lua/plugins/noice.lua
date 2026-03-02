return {
    "folke/noice.nvim",
    cond = not vim.g.vscode,
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = {
        { "<leader>nh", "<cmd>Noice history<cr>", desc = "[N]otification [H]istory" },
        { "<leader>nl", "<cmd>Noice last<cr>", desc = "[N]otification [L]ast" },
        { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "[N]otification [D]ismiss" },
    },
    opts = {
        cmdline = {
            view = "cmdline_popup",
            format = {
                cmdline = { icon = ">" },
                search_down = { icon = "/" },
                search_up = { icon = "?" },
            },
        },
        popupmenu = { enabled = true },
        lsp = {
            progress = { enabled = false }, -- fidget handles this
            signature = { enabled = false },
        },
        messages = { enabled = true },
        views = {
            cmdline_popup = {
                border = { style = "rounded" },
            },
            hover = {
                border = { style = "rounded" },
            },
            mini = {
                border = { style = "rounded" },
                position = { row = -2 },
            },
            notify = {
                border = { style = "rounded" },
            },
            popup = {
                border = { style = "rounded" },
            },
        },
    },
}
