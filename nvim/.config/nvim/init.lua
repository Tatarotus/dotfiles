require('settings')
require('keymaps')
require('plugins')
require('lsp')


-- =====================================================================
-- Sessões Invisíveis e Centralizadas (O Jeito Limpo)
-- =====================================================================
local session_dir = vim.fn.stdpath("state") .. "/sessions/"

-- Cria a pasta oculta no sistema se ela não existir
if vim.fn.isdirectory(session_dir) == 0 then
  vim.fn.mkdir(session_dir, "p")
end

-- Gera um nome de arquivo único baseado na pasta atual (ex: _home_sam_projetos.vim)
local function get_session_file()
  local path = vim.fn.getcwd():gsub("/", "_")
  return session_dir .. path .. ".vim"
end

-- 1. Salva automaticamente a sessão na pasta central ao sair
vim.api.nvim_create_autocmd("VimLeavePre", {
  desc = "Salva a sessão em uma pasta centralizada oculta",
  callback = function()
    vim.cmd("mksession! " .. vim.fn.fnameescape(get_session_file()))
  end,
})

-- 2. Restaura automaticamente ao abrir o Neovim na pasta
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Restaura a sessão automaticamente se existir",
  callback = function()
    -- Só restaura se você abriu o nvim "vazio" (sem passar um arquivo específico)
    if vim.fn.argc() == 0 then
      local file = get_session_file()
      if vim.fn.filereadable(file) == 1 then
        vim.cmd("silent! source " .. vim.fn.fnameescape(file))
      end
    end
  end,
})
