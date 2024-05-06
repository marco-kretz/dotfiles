vim.g.mapleader = " "

local keymap = vim.keymap

-- general
keymap.set("n", "<leader>nh", ":nohl<CR>")

keymap.set("n", "<leader>pv", vim.cmd.Ex)

keymap.set("n", "<leader>y", "+y")
keymap.set("n", "<leader>Y", "+yg_")
keymap.set("v", "<leader>y", "+y")

-- window splits
keymap.set("n", "<leader>sv", "<C-w>v") -- split vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make splits even
keymap.set("n", "<leader>sx", ":close<CR>") -- close split


-- Git
vim.api.nvim_set_keymap("n", "<leader>gc", ":Git commit -m \"", {noremap=false})
vim.api.nvim_set_keymap("n", "<leader>gp", ":Git push -u origin HEAD<CR>", {noremap=false})
