return {
	{
		"tpope/vim-fugitive",
		keys = {
			{ "<leader>gs", "<cmd>Git<cr>", desc = "[G]it [S]tatus" },
			{ "<leader>gb", "<cmd>Git blame<cr>", desc = "[G]it [B]lame" },
			{ "<leader>gd", "<cmd>Gvdiffsplit<cr>", desc = "[G]it [D]iff" },
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
				map("<leader>gp", gs.preview_hunk, "[G]it [P]review hunk")
				map("<leader>ga", gs.stage_hunk, "[G]it [A]dd (stage) hunk")
				map("<leader>gu", gs.undo_stage_hunk, "[G]it [U]ndo stage hunk")
			end,
		},
	},
}
