-- Migrated to the `main` branch of nvim-treesitter (the `master` branch is archived
-- and incompatible with Neovim 0.12+). The `main` API is completely different:
--   * no `nvim-treesitter.configs` module
--   * highlighting/indent are enabled per-buffer via Neovim's own treesitter runtime
--   * parsers are compiled at install time (needs the `tree-sitter` CLI + a C compiler)
local ensure_installed = {
	"bash",
	"c",
	"cpp",
	"go",
	"lua",
	"python",
	"rust",
	"typescript",
	"vim",
	"vimdoc",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- the main branch does not support lazy-loading
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup()

			-- install() is async and a no-op for already-installed parsers
			require("nvim-treesitter").install(ensure_installed)

			-- Enable highlighting (and experimental indent) per buffer. The main
			-- branch does NOT auto-enable anything; we start treesitter for any
			-- buffer whose filetype has an installed parser.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter_setup", { clear = true }),
				callback = function(ev)
					-- pcall: vim.treesitter.start() errors if no parser for this filetype
					if not pcall(vim.treesitter.start, ev.buf) then
						return
					end
					-- treesitter indent is experimental and poor for python -> skip it there
					if vim.bo[ev.buf].filetype ~= "python" then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			-- NOTE: `incremental_selection` (your old <c-space> mappings) has no
			-- equivalent on the main branch and was dropped.
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			local swap = require("nvim-treesitter-textobjects.swap")
			local move = require("nvim-treesitter-textobjects.move")

			-- select
			local selects = {
				aa = "@parameter.outer",
				ia = "@parameter.inner",
				af = "@function.outer",
				["if"] = "@function.inner",
				ac = "@class.outer",
				ic = "@class.inner",
			}
			for lhs, capture in pairs(selects) do
				vim.keymap.set({ "x", "o" }, lhs, function()
					select.select_textobject(capture, "textobjects")
				end, { desc = "Select " .. capture })
			end

			-- swap
			vim.keymap.set("n", "<leader>a", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "Swap parameter with next" })
			vim.keymap.set("n", "<leader>A", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "Swap parameter with previous" })

			-- move
			local moves = {
				goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
				goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
				goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
				goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
			}
			for fn, maps in pairs(moves) do
				for lhs, capture in pairs(maps) do
					vim.keymap.set({ "n", "x", "o" }, lhs, function()
						move[fn](capture, "textobjects")
					end, { desc = fn .. " " .. capture })
				end
			end
		end,
	},
}
