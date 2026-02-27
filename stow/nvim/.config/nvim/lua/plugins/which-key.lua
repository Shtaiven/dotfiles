return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		win = {
			border = "rounded",
		},
		spec = {
			{ "<leader>b", group = "Buffer" },
			{ "<leader>t", group = "Tab" },
			{ "<leader>f", group = "Find/Files" },
			{ "<leader>l", group = "Lazy" },
			{ "<leader>g", group = "Git" },
			{ "<leader>d", group = "Document" },
			{ "<leader>w", group = "Window/Workspace" },
			{ "<leader>c", group = "Code" },
			{ "<leader>q", group = "Quit" },
			{ "<leader>u", group = "UI Toggles" },
			{ "<leader>n", group = "Notifications" },
		},
	},
}
