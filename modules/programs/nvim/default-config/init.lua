-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Load locak config
require("set.lua")
require("keymap.lua")
require("lsp-zero.lua")
require("treesitter.lua")

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{ "nvim-treesitter/nvim-treesitter" },
		{ "neovim/nvim-lspconfig" },
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
	},
	install = { colorscheme = { "habamax" } },
	-- Autoupdate
	checker = { enabled = true },
})
