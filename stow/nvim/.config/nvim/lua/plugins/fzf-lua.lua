local function git_root()
	local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 then
		return vim.fn.getcwd()
	end
	return root
end

return {
	{
		"ibhagwan/fzf-lua",
		cond = not vim.g.vscode,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader><space>",
				function()
					require("fzf-lua").files({ cwd = git_root(), fd_opts = "--hidden" })
				end,
				desc = "Find Files",
			},
			{
				"<leader>/",
				function()
					require("fzf-lua").lgrep_curbuf()
				end,
				desc = "[/] Fuzzily search in current buffer",
			},
			{
				"<leader>ff",
				function()
					require("fzf-lua").files({ cwd = git_root(), fd_opts = "--hidden" })
				end,
				desc = "[F]ind [F]iles",
			},
			{
				"<leader>fF",
				function()
					require("fzf-lua").files({ cwd = "~", fd_opts = "--hidden" })
				end,
				desc = "[F]ind [F]iles from home",
			},
			{
				"<leader>fr",
				function()
					require("fzf-lua").oldfiles()
				end,
				desc = "[F]ind [R]ecent files",
			},
			{
				"<leader>fb",
				function()
					require("fzf-lua").buffers()
				end,
				desc = "[F]ind [B]uffers",
			},
			{
				"<leader>fh",
				function()
					require("fzf-lua").helptags()
				end,
				desc = "[F]ind [H]elp",
			},
			{
				"<leader>fw",
				function()
					require("fzf-lua").grep_cword({ cwd = git_root() })
				end,
				desc = "[F]ind current [W]ord",
			},
			{
				"<leader>fg",
				function()
					require("fzf-lua").live_grep({ cwd = git_root() })
				end,
				desc = "[F]ind by [G]rep",
			},
			{
				"<leader>fd",
				function()
					require("fzf-lua").diagnostics_workspace()
				end,
				desc = "[F]ind [D]iagnostics",
			},
			{
				"<leader>fk",
				function()
					require("fzf-lua").keymaps()
				end,
				desc = "[F]ind [K]eymaps",
			},
			{
				"<leader>f:",
				function()
					require("fzf-lua").command_history()
				end,
				desc = "[F]ind command history",
			},
			{
				'<leader>f"',
				function()
					require("fzf-lua").registers()
				end,
				desc = "[F]ind registers",
			},
			{
				"<leader>fp",
				function()
					require("fzf-lua").resume()
				end,
				desc = "[F]ind [P]revious (resume)",
			},
			{
				"<leader>fz",
				function()
					require("fzf-lua").zoxide()
				end,
				desc = "[F]ind [Z]oxide directory",
			},
			{
				"<leader>gc",
				function()
					require("fzf-lua").git_commits()
				end,
				desc = "[G]it [C]ommits",
			},
			{
				"<leader>gS",
				function()
					require("fzf-lua").git_status()
				end,
				desc = "[G]it [S]tatus",
			},
		},
		config = function()
			local function dir_or_edit(selected, opts)
				local path = require("fzf-lua").path.entry_to_file(selected[1], opts).path
				if vim.fn.isdirectory(path) == 1 then
					require("oil").open(path)
				else
					require("fzf-lua").actions.file_edit(selected, opts)
				end
			end

			require("fzf-lua").setup({
				"telescope",
				fzf_colors = true,
				files = {
					actions = {
						["default"] = dir_or_edit,
					},
				},
			})
		end,
	},
	{
		"stevearc/oil.nvim",
		cond = not vim.g.vscode,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader>fe",
				function()
					require("oil").open()
				end,
				desc = "[F]ile [E]xplorer",
			},
		},
		lazy = false,
		opts = {
			default_file_explorer = true,
			buf_options = {
				buflisted = true,
			},
			view_options = {
				show_hidden = true,
			},
			win_options = {
				signcolumn = "yes:2",
			},
		},
	},
	{
		"refractalize/oil-git-status.nvim",

		dependencies = {
			"stevearc/oil.nvim",
		},

		config = true,
	},
}
