local using_vscode = vim.g.vscode ~= nil

return {
    {
        "nvim-lualine/lualine.nvim",
        cond = not using_vscode,
        config = function()
            local c = vim.fn["gruvbox_material#get_configuration"]()
            local p = vim.fn["gruvbox_material#get_palette"](c.background, c.foreground, c.colors_override)

            local mid = { bg = p.bg_statusline2[1], fg = p.fg1[1] }

            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    theme = "gruvbox-material",
                    globalstatus = true,
                    component_separators = { left = "   ", right = "   " },
                    section_separators = { left = "▓▒░", right = "░▒▓" },
                },
                sections = {
                    lualine_a = {
                        { "mode", separator = { left = "", right = "▓▒░" } },
                    },
                    lualine_b = {
                        {
                            function()
                                return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
                            end,
                        },
                    },
                    lualine_c = {
                        { "branch", color = mid, separator = { right = "" }, draw_empty = true },
                    },
                    lualine_x = {
                        { "encoding", color = mid, separator = { left = "" }, draw_empty = true },
                        { "fileformat", color = mid },
                        { "filetype", color = mid },
                    },
                    lualine_z = {
                        { "location", separator = { left = "░▒▓", right = "" } },
                    },
                },
                tabline = {
                    lualine_a = {
                        {
                            "buffers",
                            separator = { left = "", right = "" },
                            padding = { left = 1, right = 1 },
                            buffers_color = {
                                active = { fg = p.bg0[1], bg = p.blue[1], gui = "bold" },
                                inactive = { fg = p.fg1[1], bg = p.bg_statusline3[1] },
                            },
                            draw_empty = true,
                            symbols = { alternate_file = "" },
                            filetype_names = { oil = "Oil" },
                        },
                    },
                    lualine_z = {
                        {
                            "tabs",
                            separator = { left = "", right = "" },
                            tabs_color = {
                                active = { fg = p.bg0[1], bg = p.blue[1], gui = "bold" },
                                inactive = { fg = p.fg1[1], bg = p.bg_statusline3[1] },
                            },
                        },
                    },
                },
                extensions = {
                    "fugitive",
                },
            })

            vim.api.nvim_create_autocmd("DirChanged", {
                callback = function()
                    require("lualine").refresh()
                end,
            })
        end,
    },
    {
        "brenoprata10/nvim-highlight-colors",
        opts = {
            render = "background",
            enable_named_colors = true,
            enable_tailwind = true,
        },
    },
}
