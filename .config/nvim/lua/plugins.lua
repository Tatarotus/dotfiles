vim.cmd([[
call plug#begin()
Plug 'junegunn/vim-plug'
Plug 'mattn/emmet-vim'
Plug 'EdenEast/nightfox.nvim'
Plug 'sainnhe/sonokai'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'ryanoasis/vim-devicons'
Plug 'altermo/ultimate-autopair.nvim'
Plug 'tpope/vim-commentary'
Plug 'Exafunction/codeium.nvim', { 'branch': 'main' }
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'onsails/lspkind-nvim'
Plug 'SirVer/ultisnips'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'
Plug 'L3MON4D3/LuaSnip'
Plug 'prettier/vim-prettier', { 'do': 'npm install' }
Plug 'mg979/vim-visual-multi'
Plug 'w0rp/ale'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}
Plug 'tpope/vim-surround'
Plug 'windwp/nvim-ts-autotag'
Plug 'jwalton512/vim-blade'
Plug 'pantharshit00/vim-prisma'
Plug 'sbdchd/neoformat'
Plug 'projekt0n/github-nvim-theme'
call plug#end()
]])
