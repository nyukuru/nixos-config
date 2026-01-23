vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local telescope = require("telescope.builtin")

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open file explorer" })

vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Display information about the symbol under the cursor" })
vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, { desc = "Display function signature info" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to  implementations" })
vim.keymap.set("n", "go", vim.lsp.buf.type_definition, { desc = "Go to the type definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show diagnostics" })

vim.keymap.set("n", "<leader>cm", vim.lsp.buf.code_action, { desc = "Execute availalble fixes" })

vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Find in buffers" })
vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Find in buffers" })

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Renames the symbol under the cursor" })

vim.keymap.set("v", "K", ':m "<-2<CR>gv=gv')
vim.keymap.set("v", "J", ':m ">+1<CR>gv=gv')

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", '"_dP')

vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
