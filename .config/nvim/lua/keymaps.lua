local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
map('n', '<cr>', ':w <cr>', opts)
map('n', '<cr><Esc>', ':wq! <cr>', opts)
map('i', '<C-h>', '<Left>', opts)
map('i', '<C-j>', '<Down>', opts)
map('i', '<C-k>', '<Up>', opts)
map('i', '<C-l>', '<Right>', opts)
map('i', 'jk', '<Esc>', opts)
map('n', '<PageUp>', ':tabNext <cr>', opts)
map('n', '<PageDown>', ':tabprevious <cr>', opts)
map('n', '<F5>', ':PrettierAsync<cr>:w<cr>', opts)
map('n', '<Esc>', ':NvimTreeClose<CR>', { noremap = true, silent = true })
map('n', '<C-b>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
map('n', '<Del>', ':tabclose<CR>', opts)
map('n', '<S-Del>', ':tabnew<CR>', opts)
map('n', '<space>f', ':lua require("telescope.builtin").find_files({ hidden = true })<CR>', { noremap = true, silent = true })
map('n', '<space>g', '<cmd>Telescope live_grep<cr>', opts)
map('n', '<space>b', '<cmd>Telescope buffers<cr>', opts)
map('n', '<space>h', '<cmd>Telescope help_tags<cr>', opts)
map('n', '<space>h', '<cmd>Telescope help_tags<cr>', opts)
map('i', '<C-c>', '<Cmd>call codeium#Clear()<CR>', { noremap = true, silent = true })
map('n', '<A-h>', ':ToggleTerm() size=10 direction=horizontal<CR>', { noremap = true, silent = true })
map('n', '<A-H>', ':ToggleTerm() size=20 direction=horizontal<CR>', { noremap = true, silent = true })
map('n', '<A-v>', ':ToggleTerm() size=40 direction=vertical<CR>', { noremap = true, silent = true })
map('n', '<A-V>', ':ToggleTerm() size=80 direction=vertical<CR>', { noremap = true, silent = true })
map(  't','<A-h>',  '<C-\\><C-n>'  ,  {noremap = true}  )
map(  't','<A-H>',  '<C-\\><C-n>'  ,  {noremap = true}  )
map(  't','<A-v>',  '<C-\\><C-n>'  ,  {noremap = true}  )
map(  't','<A-V>',  '<C-\\><C-n>'  ,  {noremap = true}  )
map('n', '<C-\\>', ':tab split<CR>:exec("tag ".expand("<cword>"))<CR>', { noremap = true, silent = true })
map('n', '<A-]>', ':vsp<CR>:exec("tag ".expand("<cword>"))<CR>', { noremap = true, silent = true })
map('n', '<leader>cc', ':NvimTreeCollapse<CR>', { noremap = true, silent = true })


