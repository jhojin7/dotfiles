vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.softtabstop=4
vim.opt.shiftwidth=4
vim.opt.expandtab=true
vim.opt.termguicolors = true


-- Set leader key (optional, space is a common choice)
vim.g.mapleader = ' '

-- Remap <leader>y to copy (yank) to the system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], {noremap = true, desc = "Copy to system clipboard"})

-- Remap <leader>p to paste from the system clipboard
vim.keymap.set({"n", "v", "c"}, "<leader>p", [["+p]], {noremap = true, desc = "Paste from system clipboard"})

-- -- Optional: Remap <leader>P to paste before the cursor from the system clipboard
-- vim.keymap.set({"n", "v"}, "<leader>P", [["+P]], {noremap = true, silent = true, desc = "Paste before cursor from system clipboard"})


