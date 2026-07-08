vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true

vim.g.mapleader = ' '

vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { noremap = true, desc = 'Copy to system clipboard' })
vim.keymap.set({ 'n', 'v', 'c' }, '<leader>p', [["+p]], { noremap = true, desc = 'Paste from system clipboard' })
