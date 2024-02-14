vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<leader>y", "+y")
vim.keymap.set("n", "<leader>Y", "+yg_")
vim.keymap.set("v", "<leader>y", "+y")

-- Git
vim.api.nvim_set_keymap("n", "<leader>gc", ":Git commit -m \"", {noremap=false})
vim.api.nvim_set_keymap("n", "<leader>gp", ":Git push -u origin HEAD<CR>", {noremap=false})
