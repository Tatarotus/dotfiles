local cmp = require'cmp'
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require'lspconfig'
local mason = require'mason'
local mason_lspconfig = require'mason-lspconfig'

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body) -- For UltiSnips users.
    end,
  },
  window = {
   -- completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered({
      winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
    }),
  },
  mapping = cmp.mapping.preset.insert({ 
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
        feedkey("<C-R>=UltiSnips#JumpForwards()<CR>", "")
      else
        fallback()
      end
    end, { "i", "s" }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.fn["UltiSnips#CanJumpBackwards"]() == 1 then
        feedkey("<C-R>=UltiSnips#JumpBackwards()<CR>", "")
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "codeium" },
    { name = 'nvim_lsp' },
    { name = 'ultisnips' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
  formating = {
    format = function(entry, vim_item)
      -- fancy icons and a name of kind
      vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind
      -- set a name for each source
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        codeium = "[C]",
        ultisnips = "[US]",
        buffer = "[BUF]",
        path = "[PATH]",
      })[entry.source.name]
      return vim_item
    end
  }
})

cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' },
  }, {
    { name = 'buffer' },
  })
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = true }
})

local servers = {}


mason.setup()
mason_lspconfig.setup({
  ensure_installed = servers,
  handlers = {
    function (server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})
