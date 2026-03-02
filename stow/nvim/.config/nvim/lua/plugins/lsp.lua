return {
    {
        "neovim/nvim-lspconfig",
        cond = not vim.g.vscode,
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "j-hui/fidget.nvim",
        },
        config = function()
            local servers = {
                bashls = {},
                clangd = {},
                cmake = {},
                jsonls = {},
                ruff = {},
                rust_analyzer = {},
                taplo = {},
                yamlls = {},
                lua_ls = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            }

            local on_attach = function(_, bufnr)
                local nmap = function(keys, func, desc)
                    if desc then
                        desc = "LSP: " .. desc
                    end
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
                end

                nmap("<leader>cr", vim.lsp.buf.rename, "[C]ode [R]ename")
                nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
                nmap("<leader>cl", "<cmd>LspInfo<cr>", "[C]ode [L]SP info")

                nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
                nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
                nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
                nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
                nmap("<leader>cs", require("telescope.builtin").lsp_document_symbols, "[C]ode [S]ymbols")
                nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

                nmap("K", vim.lsp.buf.hover, "Hover Documentation")
                nmap("<leader>ck", vim.lsp.buf.signature_help, "[C]ode Signature Help")

                nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
                nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
                nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
                nmap("<leader>wl", function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, "[W]orkspace [L]ist Folders")

                nmap("<leader>ch", function()
                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
                end, "[C]ode Inlay [H]ints")

                nmap("<leader>cf", function()
                    vim.lsp.buf.format()
                end, "[C]ode [F]ormat")
                vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
                    vim.lsp.buf.format()
                end, { desc = "Format current buffer with LSP" })
            end

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

            vim.keymap.set("n", "<leader>mm", "<cmd>Mason<cr>", { desc = "[M]ason open" })
            vim.keymap.set("n", "<leader>mu", "<cmd>MasonUpdate<cr>", { desc = "[M]ason [U]pdate" })

            require("mason").setup({
                ui = {
                    border = "rounded",
                },
            })

            local mason_lspconfig = require("mason-lspconfig")
            mason_lspconfig.setup({
                ensure_installed = vim.tbl_keys(servers),
            })

            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    on_attach(vim.lsp.get_client_by_id(args.data.client_id), args.buf)
                end,
            })

            for server_name, server_settings in pairs(servers) do
                if next(server_settings) ~= nil then
                    vim.lsp.config(server_name, { settings = server_settings })
                end
            end

            require("fidget").setup({
                notification = {
                    window = {
                        winblend = 0,
                        border = "rounded",
                    },
                },
            })
        end,
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
    },
}
