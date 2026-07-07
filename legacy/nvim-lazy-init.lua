-- line number
vim.opt.number = true
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

-- Installing lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
vim.opt.rtp:prepend(lazypath)
require('lazy').setup({
    {'folke/tokyonight.nvim'},
    {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/nvim-cmp'},
    {'L3MON4D3/LuaSnip'},
})


vim.opt.termguicolors = true
vim.cmd.colorscheme('tokyonight')


local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('lspconfig').tsserver.setup({})
require('lspconfig').rust_analyzer.setup({})


lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
lsp_zero.setup_servers({'lua_ls'})




