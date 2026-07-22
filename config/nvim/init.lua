vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.softtabstop=4
vim.opt.shiftwidth=4
vim.opt.expandtab=true
vim.opt.termguicolors = true


-- Set leader key (optional, space is a common choice)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remap <leader>y to copy (yank) to the system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], {noremap = true, desc = "Copy to system clipboard"})

-- Remap <leader>p to paste from the system clipboard
vim.keymap.set({"n", "v", "c"}, "<leader>p", [["+p]], {noremap = true, desc = "Paste from system clipboard"})

-- -- Optional: Remap <leader>P to paste before the cursor from the system clipboard
-- vim.keymap.set({"n", "v"}, "<leader>P", [["+P]], {noremap = true, silent = true, desc = "Paste before cursor from system clipboard"})




-- Bootstrap lazy.nvim (downloads it automatically if missing)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim and tell it to read from lua/plugins/
require("lazy").setup("plugins")

