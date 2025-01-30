local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  -- Core Plugins
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x', cmd='Telescope' },
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  { 'nvim-treesitter/nvim-treesitter-context', event = 'BufReadPost' },
  -- { 'p00f/nvim-ts-rainbow', event = 'BufReadPost' },
  { 'nvim-lualine/lualine.nvim', event = 'VimEnter' },
  { 'nvim-tree/nvim-web-devicons' },
  { 'nvim-tree/nvim-tree.lua', cmd = 'NvimTreeToggle' },
  { 'akinsho/toggleterm.nvim', tag = '*' },
  { 'windwp/nvim-ts-autotag' },


  -- LSP and Completion
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim', event = 'BufReadPre' },
  { 'neovim/nvim-lspconfig', event = 'BufReadPre' },
  { 'hrsh7th/nvim-cmp', event = 'InsertEnter' },
  { 'hrsh7th/cmp-nvim-lsp', event = 'InsertEnter', dependencies = {'hrsh7th/nvim-cmp'} },
  { 'hrsh7th/cmp-buffer', event = 'InsertEnter', dependencies = {'hrsh7th/nvim-cmp'} },
  { 'hrsh7th/cmp-path', event = 'InsertEnter', dependencies = {'hrsh7th/nvim-cmp'} },
  { 'hrsh7th/cmp-cmdline', event = 'CmdlineEnter', dependencies = {'hrsh7th/nvim-cmp'} },
  { 'onsails/lspkind-nvim', event = 'InsertEnter', dependencies = {'hrsh7th/nvim-cmp'} },

  -- Snippets
  { "hrsh7th/vim-vsnip", event = "InsertEnter", config = function()
      vim.g.vsnip_snippet_dir = "~/.config/nvim/snippets"
    end
  },
  { "hrsh7th/cmp-vsnip", event = "InsertEnter", dependencies = {"hrsh7th/vim-vsnip"} },

  -- Themes and Colors
  { 'EdenEast/nightfox.nvim', event = 'ColorScheme' },

  -- Themes and Colors
  { 'EdenEast/nightfox.nvim', event = 'ColorScheme' },
  { 'sainnhe/sonokai', event = 'ColorScheme' },
  { 'projekt0n/github-nvim-theme', event = 'ColorScheme' },

  -- Utilities
  { 'tpope/vim-commentary', event = 'BufReadPost' },
  { 'tpope/vim-surround', event = 'InsertEnter'   },
  { 'mg979/vim-visual-multi', event = 'VimEnter' },
  { 'jwalton512/vim-blade', ft = 'blade', event = 'BufReadPost', },
  { 'pantharshit00/vim-prisma', ft = 'prisma', event = 'BufReadPost' },
  { 'barrett-ruth/import-cost.nvim', 
     ft = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
     event = 'InsertEnter' },
  { 'Exafunction/codeium.nvim', branch = 'main', event = 'InsertEnter' },
  { 'Robitx/gp.nvim', event = 'BufReadPost' },
  { 'jose-elias-alvarez/null-ls.nvim', dependencies = { 'nvim-lua/plenary.nvim' }, event = 'VeryLazy' },
  -- { 'altermo/ultimate-autopair.nvim', event={'InsertEnter','CmdlineEnter'}, branch='v0.6'},
  { 'nvim-neorg/neorg', lazy = false, version = '*', config = true },
  { 'mattn/emmet-vim', lazy = true, ft = { 'html', 'css', 'blade', 'vue' } },
{ 'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  build = 'cd app && yarn install',
  init = function()
    vim.g.mkdp_filetypes = { 'markdown' }
  end,
  ft = { 'markdown' },
},


  -- Language Specific
  { 'prettier/vim-prettier', build = 'npm install', ft = {'javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'html'} },
  { 'stephpy/vim-php-cs-fixer', ft = 'php' },
  { 'StanAngeloff/php.vim', ft = 'php' },
})
