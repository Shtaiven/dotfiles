return {
    {
        "tpope/vim-fugitive",
        keys = {
            { "<leader>gs", "<cmd>Git<cr>", desc = "[G]it [S]tatus" },
            { "<leader>gb", "<cmd>Git blame<cr>", desc = "[G]it [B]lame" },
            { "<leader>gd", "<cmd>Gvdiffsplit<cr>", desc = "[G]it [D]iff" },
            { "<leader>gc", "<cmd>Telescope git_branches<cr>", desc = "[G]it [C]heckout branch" },
            { "<leader>ga", "<cmd>Telescope git_stash<cr>", desc = "[G]it stash [A]pply" },
            { "<leader>gp", "<cmd>Git stash pop<cr>", desc = "[G]it stash [P]op" },
        },
    },
    "tpope/vim-rhubarb",
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
                end

                map("]h", gs.next_hunk, "Next [H]unk")
                map("[h", gs.prev_hunk, "Prev [H]unk")
                map("<leader>gl", gs.preview_hunk, "[G]it [L]ine diff")
                map("<leader>gh", gs.stage_hunk, "[G]it stage [H]unk")
                map("<leader>gu", gs.undo_stage_hunk, "[G]it [U]ndo stage hunk")
                map("<leader>gr", gs.reset_hunk, "[G]it [R]eset hunk")
            end,
        },
    },
}
