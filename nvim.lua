--require 'paths'


print("hello from local nvim.lua")
vim.keymap.set({'n', 'v', 'i'}, "<C-b>",":!./brun.sh<CR>")
vim.keymap.set({'n', 'v', 'i'}, "<C-s>","<cmd>w<CR>")

vim.keymap.set({'n', 'v', 'i'}, "<C-q>","<cmd>q!<CR>")


vim.keymap.set({'n', 'v', 'i'}, "<F5>", "<cmd>term ./brun.sh<cr>")
vim.g.mapleader= " "
vim.keymap.set('n','<leader>pv',vim.cmd.Ex)