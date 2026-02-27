-- Set <space> as the leader key (must happen before lazy.nvim setup)
-- See `:help mapleader`
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim (auto-imports lua/plugins/*.lua)
require("lazy").setup("plugins", {
	ui = {
		border = "rounded",
		backdrop = 100,
	},
})

local using_vscode = vim.g.vscode ~= nil

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false

-- Hide the command line
vim.go.cmdheight = 0

-- Make line numbers default
vim.wo.number = true

-- Show relative line numbers
vim.o.relativenumber = true

-- Enable mouse mode
vim.o.mouse = "a"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"

-- Set colorscheme options
vim.o.termguicolors = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- Set vim to always use system clipboard if available for y, p, etc.
-- Deferred to avoid slow clipboard provider detection blocking startup
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Remove mode from command line (already shown in lualine)
vim.o.showmode = using_vscode

-- Show a line for max line length
vim.opt.colorcolumn = "100"

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Rounded borders for LSP floating windows
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
vim.diagnostic.config({ float = { border = "rounded" } })

-- Change directory to current file
vim.keymap.set("n", "<leader>cd", "<cmd>cd %:h<cr>", { desc = "[C]hange [D]irectory to current file" })

-- Save
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "Save file" })

-- Buffer navigation
vim.keymap.set("n", "<S-h>", "<cmd>bprev<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- UI toggles
vim.keymap.set("n", "<leader>us", function()
	vim.o.spell = not vim.o.spell
end, { desc = "[U]I toggle [S]pell" })
vim.keymap.set("n", "<leader>uw", function()
	vim.o.wrap = not vim.o.wrap
end, { desc = "[U]I toggle [W]rap" })
vim.keymap.set("n", "<leader>ul", function()
	vim.o.number = not vim.o.number
end, { desc = "[U]I toggle [L]ine numbers" })

-- Quit keymaps
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "[Q]uit all" })
vim.keymap.set("n", "<leader>qw", "<cmd>q<cr>", { desc = "[Q]uit [W]indow" })

-- Tab keymaps
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<cr>", { desc = "[T]ab [N]ew" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabc<cr>", { desc = "[T]ab [C]lose" })
vim.keymap.set("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "[T]ab close [O]thers" })

-- Buffer keymaps
vim.keymap.set("n", "<leader>bc", "<cmd>bd<cr>", { desc = "[B]uffer [C]lose" })
vim.keymap.set("n", "<leader>bw", "<cmd>w<cr>", { desc = "[B]uffer [W]rite" })

-- Lazy keymaps
vim.keymap.set("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "[L]azy open" })
vim.keymap.set("n", "<leader>lu", "<cmd>Lazy update<cr>", { desc = "[L]azy [U]pdate" })
vim.keymap.set("n", "<leader>ls", "<cmd>Lazy sync<cr>", { desc = "[L]azy [S]ync" })
vim.keymap.set("n", "<leader>lc", "<cmd>Lazy clean<cr>", { desc = "[L]azy [C]lean" })

-- Window keymaps
vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "[W]indow split [V]ertical" })
vim.keymap.set("n", "<leader>wh", "<C-w>s", { desc = "[W]indow split [H]orizontal" })
vim.keymap.set("n", "<leader>wc", "<C-w>c", { desc = "[W]indow [C]lose" })
vim.keymap.set("n", "<leader>wo", "<C-w>o", { desc = "[W]indow close [O]thers" })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Prev error" })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })
vim.keymap.set("n", "[w", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Prev warning" })
vim.keymap.set("n", "]w", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Next warning" })
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "[D]iagnostic float" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "[D]iagnostic [Q]uickfix list" })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- VSCode settings
if using_vscode then
	local vscode = require("vscode")

	-- use vscode notification subsystem
	vim.notify = vscode.notify

	-- make editor.action.addSelectionToNextFindMatch work correctly in any mode
	vim.keymap.set({ "n", "x", "i" }, "<C-d>", function()
		vscode.with_insert(function()
			vscode.action("editor.action.addSelectionToNextFindMatch")
		end)
	end)

	-- make editor.action.refactor work correctly on the selection and support snippet manipulation after entering VSCode snippet mode
	vim.keymap.set({ "n", "x" }, "<leader>r", function()
		vscode.with_insert(function()
			vscode.action("editor.action.refactor")
		end)
	end)
end

-- vim: ts=2 sts=2 sw=2 et
