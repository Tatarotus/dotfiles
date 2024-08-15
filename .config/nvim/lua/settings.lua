-- Basic Settings
vim.opt.termguicolors = true
vim.cmd('colorscheme dayfox')

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
local autopair = require'ultimate-autopair'

treesitter.setup {
  ensure_installed = { "javascript", "tsx", "html", "css", "lua", "php"},
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
    file_ignore_patterns = {"node_modules"},
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
    'javascript', 'typescript', 'python', 'lua', 'go', 'rust', 'java'
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



autopair.setup({
  -- General configuration
  pair_map = true,
  map = true,
  fast_wrap = true,
  multi = true,

  -- Enable autopair in all modes
  enable_always = true,
  enable_single_quote_pair = true,
  enable_bracket_pair = true,
  enable_curly_pair = true,
  enable_angle_pair = true,
  enable_backtick_pair = true,
  enable_parenthesis_pair = true,

  -- Disable checks that might prevent autopair
  check_not_in_macro = false,
  check_not_in_string = false,
  check_not_in_quotes = false,
  check_not_before_text = false,
  check_not_after_text = false,
})
