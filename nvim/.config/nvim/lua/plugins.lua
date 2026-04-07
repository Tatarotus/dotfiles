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

  -- Treesitter
  { 
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local function register_neorg_parsers()
        local parser_configs = require('nvim-treesitter.parsers')
        if parser_configs.get_parser_configs then
          parser_configs = parser_configs.get_parser_configs()
        end

        parser_configs.norg = {
          install_info = {
            url = 'https://github.com/nvim-neorg/tree-sitter-norg',
            files = { 'src/parser.c', 'src/scanner.cc' },
            revision = '6348056b999f06c2c7f43bb0a5aa7cfde5302712',
            use_makefile = true,
          },
        }

        parser_configs.norg_meta = {
          install_info = {
            url = 'https://github.com/nvim-neorg/tree-sitter-norg-meta',
            files = { 'src/parser.c' },
            revision = 'a479d1ca05848d0b51dd25bc9f71a17e0108b240',
            use_makefile = true,
          },
        }
      end

      vim.api.nvim_create_autocmd('User', {
        pattern = 'TSUpdate',
        callback = register_neorg_parsers,
      })

      register_neorg_parsers()

      local parser_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'parser')
      -- Neorg's norg parser currently needs the bootstrap script at
      -- ~/.config/nvim/setup-neorg-parser.sh because :TSInstall norg uses an
      -- incompatible tree-sitter-cli build path for scanner.cc.
      pcall(vim.treesitter.language.add, 'norg', {
        path = vim.fs.joinpath(parser_dir, 'norg.so'),
      })
      pcall(vim.treesitter.language.add, 'norg_meta', {
        path = vim.fs.joinpath(parser_dir, 'norg_meta.so'),
      })

      require("nvim-treesitter.config").setup {
        ensure_installed = { "lua", "vim", "vimdoc", "query", "markdown" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
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

  -- Neorg
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {},
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/notes",
              },
              default_workspace = "notes",
            },
          },
          -- You can uncomment this once everything is stable
          -- ["core.esupports.metagen"] = { config = { type = "auto" } },
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
