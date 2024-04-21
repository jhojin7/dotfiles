-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- colorscheme nord.nvim
    use 'shaunsingh/nord.nvim'
    vim.cmd[[colorscheme nord]]




    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    -- nvim-treesitter
    use( 'nvim-treesitter/nvim-treesitter', {run=':TSUpdate'})


end
)
