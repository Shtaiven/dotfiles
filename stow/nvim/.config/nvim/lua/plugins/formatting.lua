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
		opts = {
			ensure_installed = { "stylua" },
		},
	},
}
