return {
	{
		"stevearc/conform.nvim",
		cond = not vim.g.vscode,
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},
	{
		"williamboman/mason.nvim",
		cond = not vim.g.vscode,
		-- NOTE: mason.nvim has no `ensure_installed` option (that is mason-lspconfig
		-- for servers / mason-tool-installer for everything else). Tools used by
		-- conform must be installed by hand: `:MasonInstall stylua`.
		opts = {
			ui = {
				border = "rounded",
			},
		},
	},
}
