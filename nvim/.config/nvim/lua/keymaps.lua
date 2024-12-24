local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
-- map('n', '<cr>', ':w <cr>', opts)
-- map('n', '<cr><Esc>', ':wq! <cr>', opts)
map('n', '<leader>fi', [[:lua vim.opt.foldmethod = 'indent'<CR>]], { noremap = true, silent = true })
map('i', '<C-h>', '<Left>', opts)
map('i', '<C-j>', '<Down>', opts)
map('i', '<C-k>', '<Up>', opts)
map('i', '<C-l>', '<Right>', opts)
map('i', 'jk', '<Esc>', opts)
map('n', '<PageUp>', ':tabNext <cr>', opts)
map('n', '<PageDown>', ':tabprevious <cr>', opts)
map('n', '<cr>', ':w <cr>', opts)
map('n', '<F5>', ':PrettierAsync<cr>:w<cr>', opts)
map('n', '<Esc>', ':NvimTreeClose<CR>', { noremap = true, silent = true })
map('n', '<C-b>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
map('n', '<space><space>', ':NvimTreeFindFile<CR>', { noremap = true, silent = true })
map('n', 'T', ':tabnew<CR>', { noremap = true, silent = true })
map('n', 'Q', ':tabclose<CR>', { noremap = true, silent = true })
map('n', '<space>f', ':lua require("telescope.builtin").find_files({ hidden = true })<CR>', { noremap = true, silent = true })
map('n', '<space>g', '<cmd>Telescope live_grep<cr>', opts)
map('n', '<space>b', '<cmd>Telescope buffers<cr>', opts)
map('n', '<space>h', '<cmd>Telescope help_tags<cr>', opts)
map('n', '<space>h', '<cmd>Telescope help_tags<cr>', opts)
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
map('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })
map('n', '<C-c>', ':GpRewrite<CR>', {silent = true, noremap = true, expr = false})
map("n", "<leader>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", { noremap = true, silent = true })
map('i', '<C-j>', 'vsnip#available(1) ? "<Plug>(vsnip-expand)" : "<C-j>"', {expr = true})

-- local function map(mode, lhs, rhs, opts)
--   local options = { noremap = true, silent = true }
--   if opts then
--     options = vim.tbl_extend('force', options, opts)
--   end
--   vim.api.nvim_set_keymap(mode, lhs, rhs, options)
-- end


-- local wk = require("which-key")

-- wk.add({
--   { "<leader>f", group = "file" }, -- group
--   { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
--   { "<leader>fb", function() print("hello") end, desc = "Foobar" },
--   { "<leader>fn", desc = "New File" },
--   { "<leader>f1", hidden = true }, -- hide this keymap
--   { "<leader>w", proxy = "<c-w>", group = "windows" }, -- proxy to window mappings
--   { "<leader>b", group = "buffers", expand = function()
--       return require("which-key.extras").expand.buf()
--     end
--   },
--   {
--     -- Nested mappings are allowed and can be added in any order
--     -- Most attributes can be inherited or overridden on any level
--     -- There's no limit to the depth of nesting
--     mode = { "n", "v" }, -- NORMAL and VISUAL mode
--     { "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
--     { "<leader>w", "<cmd>w<cr>", desc = "Write" },
--   }
-- })
--
