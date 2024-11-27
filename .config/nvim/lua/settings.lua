-- Basic Settings
vim.opt.termguicolors = true
vim.cmd('colorscheme dayfox')
-- vim.cmd('colorscheme github_light')

vim.cmd('syntax on')
vim.opt.mouse = 'a'
vim.opt.cursorline = true
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.showtabline = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.clipboard:append{'unnamed', 'unnamedplus'}
vim.opt.number = true
vim.opt.relativenumber = true

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Enable Emmet for HTML, JSX, and JavaScript files
vim.cmd [[
autocmd FileType html,css,scss,javascript.jsx EmmetInstall
]]

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

vim.g.ale_linters = { javascript = { 'eslint' } }
vim.g.ale_fixers = { javascript = { 'eslint' } }

vim.g.UltiSnipsSnippetDirectories = { "~/.config/nvim/UltiSnips" }
vim.cmd [[autocmd BufNewFile,BufRead *.blade.php set filetype=blade]]

vim.api.nvim_create_autocmd("FileType", {
    pattern = "javascriptreact",
    callback = function()
        vim.cmd("UltiSnipsAddFiletypes javascriptreact")
    end,
})

vim.g.UltiSnipsExpandTrigger = "<tab>"


local treesitter = require'nvim-treesitter.configs'
local lualine = require'lualine'
local toggleterm = require'toggleterm'
local telescope = require'telescope'
local nvim_tree = require'nvim-tree'
local codeium = require'codeium'

treesitter.setup {
  ensure_installed = { "javascript", "tsx", "html", "css", "lua", "php", "typescript"},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  autotag = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = { enable = true }
}

lualine.setup {
  sections = {
    lualine_b = { { 'filename', file_status = true } },
    lualine_c = { { 'diagnostics', sources = { 'nvim_diagnostic' } } },
    lualine_x = { 'encoding', 'filetype' },
    lualine_y = { { 'branch', icon = '' } },
  },
}

toggleterm.setup()

telescope.setup{
  defaults = {
  file_ignore_patterns = { "^vendor/", "^node_modules/" },
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
      '--no-ignore',
      '--glob',
      '!.git/',
      '--glob', '!**/composer/*',  -- ignore all composer related directories
      '--glob', '!vendor/*',  -- ignore vendor folder

    },
  },
  pickers = {
    find_files = {
     find_command = {'rg', '--files',  '--no-ignore', '--hidden', '--glob', '!.git/', '--glob', '!node_modules/*'},
    }
  },
}

vim.api.nvim_set_keymap('n', '<space>fh', ':lua require("telescope.builtin").find_files({ hidden = true })<CR>', { noremap = true, silent = true })


nvim_tree.setup {
  update_cwd = true,  -- update the current working directory
  view = {
    width = 30,
    side = 'left',
  },
  filters = {
    dotfiles = false, -- don't hide dotfiles
  },
  git = {
    enable = true,
    ignore = false,  -- don't ignore files based on .gitignore
  },
}

codeium.setup {
  enable = true,               -- Enable the plugin
  filetypes = {                -- Filetypes to enable codeium on
    'javascript', 'typescript', 'python', 'lua', 'go', 'rust', 'java', 'blade'
  },
  completion = {
    enabled = true,            -- Enable code completion
    auto_trigger = true,       -- Auto-trigger completion
  },
  inline_suggestions = {
    enabled = true,            -- Enable inline suggestions
  },
  hover = {
    enabled = true,            -- Enable hover documentation
  },
  enable_chat = {
    enable = true
  }
}

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.ts", "*.tsx"},
  callback = function()
    if vim.fn.expand("%:e") == "tsx" then
      vim.bo.filetype = "typescriptreact"
    else
      vim.bo.filetype = "typescript"
    end
  end
})

vim.g.neoformat_prisma_prettier = {
    exe = 'prettier',
    args = {'--stdin-filepath', '"%:p"', '--parser', 'prisma'},
    stdin = 1,
}

vim.g.neoformat_enabled_prisma = {'prettier'}

-- Enable autoformatting on save for Prisma files
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.prisma",
    command = "undojoin | Neoformat",
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', 'gr', builtin.lsp_references, {})

local import_cost = require'import-cost'
import_cost.setup()


require('gp').setup({
  providers = {
    openai = {
      endpoint = "https://api.x.ai/v1/chat/completions",
      secret = os.getenv("OPENAI_API_KEY"),
    },
  },
})


local null_ls = require("null-ls")
-- Register built-in sources for linting and formatting
null_ls.setup({
debbug = true,
    sources = {
        -- Formatting
        null_ls.builtins.formatting.prettier, -- for JavaScript/TypeScript/HTML/CSS
        null_ls.builtins.formatting.stylua, -- for Lua
        null_ls.builtins.formatting.phpcsfixer, -- for PHP
        require("none-ls.diagnostics.eslint_d"), -- for JS
        null_ls.builtins.diagnostics.phpcs, -- for PHP
    },
    -- Diagnostics display customization (optional)
    diagnostics_format = "[#{c}] #{m} (#{s})",
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
        end
    end,
})


