call plug#begin()
Plug 'sainnhe/sonokai'
"Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
"Plug 'feline-nvim/feline.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-commentary' 
Plug 'Exafunction/codeium.vim', { 'branch': 'main' }
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
" Plug 'hrsh7th/cmp-buffer'
" Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'L3MON4D3/LuaSnip'
Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v3.x'}
" Plug 'hrsh7th/cmp-vsnip'
" Plug 'hrsh7th/vim-vsnip'
Plug 'prettier/vim-prettier', { 'do': 'npm install' }
Plug 'mg979/vim-visual-multi'
Plug 'w0rp/ale'
call plug#end()

"------------------------------Theme-----------------------------------------------------------
set termguicolors

let g:lightline = {'colorscheme' : 'sonokai'}
let g:airline_theme = 'sonokai'

let g:sonokai_style = 'andromeda'
let g:sonokai_enable_italic = 0
let g:sonokai_disable_italic_comment = 0

colorscheme sonokai  
 " colorscheme catppuccin-macchiato " catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
hi Normal guibg=NONE ctermbg=NONE

"-----------------------------Basic Settings---------------------------------------------------
syntax on

:set mouse=a
:set cursorline

"tab indentation
:set shiftwidth=2
:set autoindent
:set smartindent
:set showtabline=2

"tab size
:set tabstop=2
:set shiftwidth=2
:set expandtab

"set copy
set clipboard^=unnamed,unnamedplus

"set line numbers
:set number relativenumber

"set keymaps

nnoremap <cr> :w <cr>

inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap jk <Esc>
nnoremap <F11> :bufdo tab split<CR>:tablast<CR>:tabclose<CR>:syntax on<CR>
nnoremap <PageUp> :tabNext <cr>
nnoremap <PageDown> :tabprevious <cr>
nnoremap <F5> :Prettier <cr> :w <cr>
nnoremap <space> :NERDTreeToggle <cr>
nnoremap <silent> <C-b> :NERDTreeToggle<CR>
nnoremap <Del> :tabclose <CR>

"----------------------------Plugin Settings---------------------------------------------------
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = []
let g:NERDTreeStatusline = ''
" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Open in tab
let NERDTreeCustomOpenArgs={'file':{'where': 't'}}


"ESLINT
let b:ale_linters = ['eslint']
let g:ale_fixers = {
 \ 'javascript': ['eslint']
 \ }
 
" let g:ale_sign_error = '❌'
" let g:ale_sign_warning = '⚠'

"---------------------------Custom Functions--------------------------------------------------
" Terminal Function @Thanks anonyous reddit user
let g:term_buf = 0
let g:term_win = 0
function! TermToggle(height)
    if win_gotoid(g:term_win)
        hide
    else
        botright new
        exec "resize " . a:height
        try
            exec "buffer " . g:term_buf
        catch
            call termopen($SHELL, {"detach": 0})
            let g:term_buf = bufnr("")
            set nonumber
            set norelativenumber
            set signcolumn=no
        endtry
        startinsert!
        let g:term_win = win_getid()
    endif
endfunction



" Toggle terminal on/off (neovim)
nnoremap <A-h> :call TermToggle(9)<CR>
inoremap <A-h> <Esc>:call TermToggle(9)<CR>
tnoremap <A-h> <C-\><C-n>:call TermToggle(9)<CR>

" Terminal go back to normal mode
tnoremap <Esc> <C-\><C-n>
tnoremap :q! <C-\><C-n>:q!<CR>


" Status bar

"-----------------------Lua Scripts------------------------------------------------------------
lua <<EOF

  require('lualine').setup{
    sections = {
      lualine_c = {},
      lualine_x = {'encoding', 'filename'}
    }
  }

  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
       documentation = cmp.config.window.bordered(),
   --   documentation = cmp.config.window.bordered({
     --      winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
      --  }),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
   -- ['<Tab>'] = cmp.mapping.select_next_item(),
   -- ['<S-Tab>'] = cmp.mapping.select_prev_item(),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
     -- { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
--  require('lspconfig')['cssls'].setup {
 --   capabilities = capabilities
--  }

  --require('lspconfig')['lua_ls'].setup {
   -- capabilities = capabilities
  --}

 -- require('lspconfig')['emmet_ls'].setup {
  --  capabilities = capabilities
 -- }

  local lsp_zero = require('lsp-zero')

  lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({buffer = bufnr})
  end) 

 local lspconfig = require'lspconfig'
 local servers = {}

  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
      capabilities = capabilities,
    }
  end

  -- automatic set up

  local lsp_zero = require('lsp-zero')

  lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({buffer = bufnr})
  end)

  -- to learn how to use mason.nvim
  -- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guide/integrate-with-mason-nvim.md
  require('mason').setup({})
  require('mason-lspconfig').setup({
    ensure_installed = {},
    handlers = {
      function(server_name)
        require('lspconfig')[server_name].setup({})
      end,
    },
  })
--EOF

