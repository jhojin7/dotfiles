
-- line number
vim.opt.number = true
-- line relative number
-- vim.opt.relativenumber = true
-- line wrap
vim.opt.wrap = false
-- use mouse
vim.opt.mouse = 'a'
-- highlight previous search results
vim.opt.hlsearch = false

-- tab key as spaces
vim.opt.expandtab = true
-- tab spaces
vim.opt.tabstop = 4
-- tab spaces for << >>
vim.opt.shiftwidth = 4
-- ???
vim.opt.softtabstop = 4

-- leader key
vim.g.mapleader = ' '


-- lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    }
    -- "folke/which-key.nvim",
})


vim.cmd[[colorscheme tokyonight]]

