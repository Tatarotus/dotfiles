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

-- Plugin Settings
vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeMinimalUI = 1
vim.g.NERDTreeIgnore = {}
vim.g.NERDTreeStatusline = ''

vim.g.ale_linters = { javascript = { 'eslint' } }
vim.g.ale_fixers = { javascript = { 'eslint' } }

vim.g.UltiSnipsSnippetDirectories = { "~/.config/nvim/UltiSnips" }

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

treesitter.setup {
  ensure_installed = { "javascript", "tsx" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
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

