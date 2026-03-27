-- Core Neovim Settings
vim.g.mapleader = " "
vim.opt.background = 'light'
vim.opt.termguicolors = true
vim.opt.mouse = 'a'
vim.opt.cursorline = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.showtabline = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = 'unnamedplus'

-- Disable netrw (if using nvim-tree or similar)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Custom filetype detection
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.ts", "*.tsx"},
  callback = function()
    local ext = vim.fn.expand("%:e")
    vim.bo.filetype = ext == "tsx" and "typescriptreact" or "typescript"
  end,
})
