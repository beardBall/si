--require 'paths'


--print("hello from local nvim.lua")
vim.keymap.set({'n', 'v', 'i'}, "<C-b>","<cmd>w<CR><cmd>! ./brun.sh<CR>")
vim.keymap.set({'n', 'v', 'i'}, "<C-s>","<cmd>w<CR>")

vim.keymap.set({'n', 'v', 'i'}, "<C-q>","<cmd>q<CR>")


vim.keymap.set({'n', 'v', 'i'}, "<F5>", "<cmd>term ./brun.sh<cr>")
vim.g.mapleader= " "
vim.keymap.set('n','<leader>pv',vim.cmd.Ex)
vim.keymap.set({'n','v'}, "<leader>w", "<cmd>w<CR>")
vim.keymap.set({'n','v', 'i'}, "<leader>q", "<cmd>q<CR>")

vim.cmd ":Neotree reveal_file=src/main.cpp"

