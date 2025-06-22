vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Displays hover information about the symbol under the cursor
vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")

-- Jump to the definition
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")

-- Jump to declaration
vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")

-- Lists all the implementations for the symbol under the cursor
vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>")

-- Jumps to the definition of the type symbol
vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>")

-- Lists all the references
vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>")

-- Displays a function's signature information
vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>")

-- Renames all references to the symbol under the cursor
vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>")

-- Show diagnostics in a floating window
vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>")

-- Move to the previous diagnostic
vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>")

-- Move to the next diagnostic
vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>vwm", function()
	require("vim-with-me").StartVimWithMe()
end)
vim.keymap.set("n", "<leader>svwm", function()
	require("vim-with-me").StopVimWithMe()
end)

-- greatest remap ever
vim.keymap.set("x", "<leader>p", '"_dP')

-- next greatest remap ever : asbjornHaland
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", function()
	vim.lsp.buf.format()
end)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
