local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- General Mappings
map('i', 'jk', '<Esc>', opts)
map('n', '<cr>', ':w <cr>', opts)
map('n', 'te', ':tabnew<CR>', opts)
map('n', 'tc', ':tabclose<CR>', opts)
map('n', '<PageUp>', ':tabNext <cr>', opts)
map('n', '<PageDown>', ':tabprevious <cr>', opts)

-- Navigation (Insert Mode)
map('i', '<C-h>', '<Left>', opts)
map('i', '<C-j>', '<Down>', opts)
map('i', '<C-k>', '<Up>', opts)
map('i', '<C-l>', '<Right>', opts)

-- Telescope
map('n', '<leader>f', ':Telescope find_files hidden=true<CR>', opts)
map('n', '<space>g', '<cmd>Telescope live_grep<cr>', opts)
map('n', '<space>b', '<cmd>Telescope buffers<cr>', opts)
map('n', '<space>h', '<cmd>Telescope help_tags<cr>', opts)

-- NvimTree
map('n', '<C-b>', ':NvimTreeToggle<CR>', opts)
map('n', '<space><space>', ':NvimTreeFindFile<CR>', opts)

-- ToggleTerm
map('n', '<A-h>', ':ToggleTerm direction=horizontal<CR>', opts)
map('n', '<A-v>', ':ToggleTerm direction=vertical<CR>', opts)
map('t', '<A-h>', [[<C-\><C-n>]], opts)
map('t', '<A-v>', [[<C-\><C-n>]], opts)

-- LSP
map('n', '<leader>e', vim.diagnostic.open_float, opts)
-- map("n", "<leader>f", vim.lsp.buf.format, opts)

-- GP (AI)
-- map('n', '<C-c>', ':GpRewrite<CR>', opts)
-- map('n', '<leader>gn', ':GpChatNew<CR>', opts)

-- Markdown Preview
map('n', '<C-p>', ':MarkdownPreviewToggle<CR>', opts)
