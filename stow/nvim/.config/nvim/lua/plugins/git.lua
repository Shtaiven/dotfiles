return {
	{
		"tpope/vim-fugitive",
		-- `cmd` so `:Git`/`:GBrowse` typed by hand work before any fugitive keymap
		-- has fired (same reason fzf-lua declares `cmd = "FzfLua"`).
		cmd = { "Git", "GBrowse" },
		keys = {
			{ "<leader>gs", "<cmd>Git<cr>", desc = "[G]it [S]tatus" },
			{ "<leader>gb", "<cmd>Git blame<cr>", desc = "[G]it [B]lame" },
			{ "<leader>gd", "<cmd>Gvdiffsplit<cr>", desc = "[G]it [D]iff" },
			{ "<leader>go", "<cmd>FzfLua git_branches<cr>", desc = "[G]it check[O]ut branch" },
			{ "<leader>ga", "<cmd>FzfLua git_stash<cr>", desc = "[G]it stash [A]pply" },
			{ "<leader>gp", "<cmd>Git stash pop<cr>", desc = "[G]it stash [P]op" },
			-- :GBrowse needs a per-forge handler; vim-rhubarb below supplies the
			-- GitHub one. `:` rather than `<cmd>` in visual mode so the '<,'> range
			-- comes along and the URL points at the selected lines.
			{ "<leader>gw", ":GBrowse<cr>", mode = { "n", "x" }, desc = "[G]it [W]eb open" },
			{ "<leader>gW", ":GBrowse!<cr>", mode = { "n", "x" }, desc = "[G]it [W]eb copy URL" },
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
				map("<leader>gR", gs.reset_buffer, "[G]it [R]eset buffer")
				map("<leader>gB", gs.blame_line, "[G]it [B]lame line")
				map("<leader>gt", gs.toggle_current_line_blame, "[G]it [T]oggle line blame")
				map("<leader>gD", gs.diffthis, "[G]it [D]iff this")
			end,
		},
	},
}
