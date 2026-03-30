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
  -- UI & Theme
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require('github-theme').setup({
        options = {
          transparent = false,
          styles = {
            sidebars = "depth",
            floats = "transparent",
          },
        },
      })
      vim.cmd('colorscheme github_light')
    end,
  },
  { 'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require'lualine'.setup {
        sections = {
          lualine_b = { { 'filename', file_status = true } },
          lualine_c = { { 'diagnostics', sources = { 'nvim_diagnostic' } } },
          lualine_x = { 'encoding', 'filetype' },
          lualine_y = { { 'branch', icon = '' } },
        },
      }
    end
  },

  -- Core Utilities
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    cmd = 'Telescope',
    config = function()
      require'telescope'.setup{
        defaults = {
          file_ignore_patterns = { "^vendor/", "^node_modules/" },
        },
      }
    end
  },
  { 'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require'nvim-treesitter.configs'.setup {
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
      }
    end
  },
  { 'nvim-tree/nvim-tree.lua',
    cmd = 'NvimTreeToggle',
    config = function()
      require'nvim-tree'.setup {
        update_cwd = true,
        actions = { open_file = { window_picker = { enable = false } } },
        view = { adaptive_size = true, side = 'left' },
      }
    end
  },
  { 'akinsho/toggleterm.nvim', tag = '*', config = true },
  { 'windwp/nvim-ts-autotag' },

  -- LSP and Completion
  { 'williamboman/mason.nvim', config = true },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'onsails/lspkind-nvim',
      'hrsh7th/vim-vsnip',
      'hrsh7th/cmp-vsnip',
    }
  },

  -- Productivity
  { 'tpope/vim-commentary' },
  { 'tpope/vim-surround' },
  { 'Exafunction/codeium.nvim',
    config = function()
      require'codeium'.setup {
        enable = true,
        virtual_text = {
          enabled = true,
          key_bindings = {
            accept = "<S-Tab>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-e>",
          },
        },
        completion = { enabled = true, auto_trigger = true },
      }
    end
  },
  { 'Robitx/gp.nvim', config = true },
  {
    "nvim-neorg/neorg",
    lazy = false,  -- Neorg recommends disabling lazy-loading to ensure everything hooks up correctly
    version = "*",
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {},  -- Loads default behavior, essential mappings, and logic
          ["core.concealer"] = {}, -- Adds pretty icons and enables syntax concealing
          ["core.dirman"] = {      -- Manages your Neorg workspaces
            config = {
              workspaces = {
                notes = "~/notes", -- Change this path to wherever you want to store your notes
              },
              default_workspace = "notes",
            },
          },
        },
      })
    end,
  },
  { 'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview' },
    build = 'cd app && yarn install',
    ft = { 'markdown' },
  },
  { 'folke/flash.nvim', event = "VeryLazy", config = true },

  -- Language Support
  { 'jwalton512/vim-blade', ft = 'blade' },
  { 'prettier/vim-prettier', build = 'bun install', ft = {'javascript', 'typescript', 'css', 'json', 'markdown', 'html'} },
})
