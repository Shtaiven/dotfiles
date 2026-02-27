return {
	"mrjones2014/smart-splits.nvim",
	cond = not vim.g.vscode,
	lazy = false,
	keys = {
		{
			"<C-h>",
			function()
				require("smart-splits").move_cursor_left()
			end,
			desc = "Move to left window",
		},
		{
			"<C-j>",
			function()
				require("smart-splits").move_cursor_down()
			end,
			desc = "Move to window below",
		},
		{
			"<C-k>",
			function()
				require("smart-splits").move_cursor_up()
			end,
			desc = "Move to window above",
		},
		{
			"<C-l>",
			function()
				require("smart-splits").move_cursor_right()
			end,
			desc = "Move to right window",
		},
		{
			"<C-A-h>",
			function()
				require("smart-splits").resize_left()
			end,
			desc = "Resize window left",
		},
		{
			"<C-A-j>",
			function()
				require("smart-splits").resize_down()
			end,
			desc = "Resize window down",
		},
		{
			"<C-A-k>",
			function()
				require("smart-splits").resize_up()
			end,
			desc = "Resize window up",
		},
		{
			"<C-A-l>",
			function()
				require("smart-splits").resize_right()
			end,
			desc = "Resize window right",
		},
	},
}
