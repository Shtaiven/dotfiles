return {
    "sainnhe/gruvbox-material",
    cond = not vim.g.vscode,
    lazy = false,
    priority = 1000,
    config = function()
        vim.g.gruvbox_material_disable_italic_comment = 1
        vim.g.gruvbox_material_background = "hard"
        vim.g.gruvbox_material_dim_inactive_windows = 1
        vim.g.gruvbox_material_diagnostic_text_highlight = 1
        vim.g.gruvbox_material_disable_terminal_colors = 1
        vim.g.gruvbox_material_transparent_background = 2
        vim.g.gruvbox_material_better_performance = 1
        vim.cmd([[colorscheme gruvbox-material]])
        vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "WinSeparator", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "FloatTitle", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "LazyNormal", { bg = "NONE", fg = "NONE" })
    end,
}
