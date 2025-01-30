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
vim.opt.number = true
vim.opt.relativenumber = true

-- Disable clipboard for delete and cut by mapping to the black hole register
-- local mappings = {
--     { 'n', 'd', '"_d' },
--     { 'n', 'D', '"_D' },
--     { 'n', 'c', '"_c' },
--     { 'n', 'C', '"_C' },
--     { 'n', 'x', '"_x' },
--     { 'n', 'X', '"_X' },
--     { 'v', 'd', '"_d' },
--     { 'v', 'x', '"_x' },
-- }
--
-- for _, map in ipairs(mappings) do
--     vim.api.nvim_set_keymap(map[1], map[2], map[3], opts)
-- end


-- local opts = { noremap = true, silent = true }
-- for _, mode in ipairs({ "n", "v" }) do
--     vim.api.nvim_set_keymap(mode, "d", '"_d', opts)
--     vim.api.nvim_set_keymap(mode, "x", '"_x', opts)
-- end


-- Optionally, enable clipboard integration for yank
vim.opt.clipboard = 'unnamedplus'

-- Disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Treesitter configuration
require'nvim-treesitter.configs'.setup {
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  rainbow = {
      enable = true,
      extended_mode = true, 
      max_file_lines = nil,
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

-- Lualine configuration
require'lualine'.setup {
  sections = {
    lualine_b = { { 'filename', file_status = true } },
    lualine_c = { { 'diagnostics', sources = { 'nvim_diagnostic' } } },
    lualine_x = { 'encoding', 'filetype' },
    lualine_y = { { 'branch', icon = '' } },
  },
}

-- Toggleterm configuration
require'toggleterm'.setup()

-- Telescope configuration
require'telescope'.setup{
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
      '--glob', '!**/composer/*',
      '--glob', '!vendor/*',
    },
  },
  pickers = {
    find_files = {
      find_command = {'rg', '--files', '--no-ignore', '--hidden', '--glob', '!.git/', '--glob', '!node_modules/*'},
    }
  },
}

-- Nvim-tree configuration
require'nvim-tree'.setup {
  update_cwd = true,  -- update the current working directory
  actions = {
    open_file = {
      window_picker = {
        enable = false, -- Avoid picking an existing window for new tabs
      },
    },
  },
  view = {
    adaptive_size = true,
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

-- Codeium configuration
require'codeium'.setup {
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

-- Autopair configuration
-- require'ultimate-autopair'.setup({
--   pair_map = true,
--   map = true,
--   fast_wrap = true,
--   multi = true,
--   enable_single_quote_pair = true,
--   enable_bracket_pair = true,
--   enable_curly_pair = true,
--   enable_angle_pair = true,
--   enable_backtick_pair = true,
--   enable_parenthesis_pair = true,
-- })

-- Custom filetype detection for JavaScript React and Blade files
local au = vim.api.nvim_create_autocmd

au({"BufNewFile", "BufRead"}, {
  pattern = {"*.ts", "*.tsx"},
  callback = function()
    local ext = vim.fn.expand("%:e")
    vim.bo.filetype = ext == "tsx" and "typescriptreact" or "typescript"
  end,
})

-- GP setup for Grok-beta integration
require('gp').setup({
  providers = {
    samba = {
      endpoint = "https://api.sambanova.ai/v1/chat/completions",
      secret = os.getenv("SAMBA_KEY"),
    },
    grok = {
      endpoint = "https://api.x.ai/v1/chat/completions",
      secret = os.getenv("OPENAI_API_KEY"),
    },
    kluster = {
      endpoint = "https://api.kluster.ai/v1/chat/completions",
      secret = os.getenv("KLUSTER_KEY"),
    },
    groq = {
      endpoint = "https://api.groq.com/openai/v1/chat/completions",
      secret = os.getenv("GROQ_KEY"),
    },
  },
})


-- Null-ls setup for linting and formatting
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        -- Formatting
        null_ls.builtins.formatting.prettier, -- for JavaScript/TypeScript/HTML/CSS
        null_ls.builtins.formatting.stylua, -- for Lua
        null_ls.builtins.formatting.phpcsfixer, -- for PHP
        null_ls.builtins.diagnostics.eslint.with({
            diagnostics_format = "[eslint] #{m} (#{c})",
        }),
        -- Diagnostics
        -- null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.diagnostics.phpcs.with({
              -- extra_args = { "--standard=PSR12" },
                 filetypes = { "php", "blade" },
                 extra_args = { "Laravel" },
        }),
    },
    diagnostics_format = "[#{c}] #{m} (#{s})",
    on_attach = function(client, bufnr)
        -- if client.supports_method("textDocument/formatting") then
        --     vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
        -- end
        if vim.bo.filetype == "php" or vim.bo.filetype == "blade" then
            vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
        end
    end,
})


-- Noice setup for enhanced UI elements
-- require("noice").setup({
--   lsp = {
--     override = {
--       ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
--       ["vim.lsp.util.stylize_markdown"] = true,
--       ["cmp.entry.get_documentation"] = true,
--     },
--   },
--   cmdline = {
--     enabled = true,
--     view = "cmdline",
--     format = {
--       cmdline = { pattern = "^:", icon = "", lang = "vim" },
--       search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
--       search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
--       filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
--       lua = { pattern = "^:%s*lua%s+", icon = "lua", lang = "lua" },
--     },
--   },
--   routes = {
--     {
--       filter = {
--         event = "msg_show",
--         kind = "",
--         find = "written",
--       },
--       opts = { skip = true },
--     },
--   },
--   presets = {
--     bottom_search = true,
--     command_palette = true,
--     long_message_to_split = true,
--     inc_rename = false,
--     lsp_doc_border = false,
--   },
-- })

-- -- Autocommands for toggling Noice with nvim-tree
-- au("BufEnter", {
--     pattern = "NvimTree_*",
--     callback = function()
--         require("noice").disable()
--     end,
-- })
-- au("BufLeave", {
--     pattern = "NvimTree_*",
--     callback = function()
--         require("noice").enable()
--     end,
-- })
--
--
require('neorg').setup {
  load = {
    ["core.autocommands"] = {},
    ["core.integrations.treesitter"] = {},
    ["core.concealer"] = {},
    ["core.defaults"] = {},
    ["core.export"] = {
      config = {
        -- Additional export options (e.g., setting a default export folder)
        markdown = {
          -- Customize export settings for Markdown
          include_timestamps = true,
          -- Define custom export command behavior
        }
      }
    },
    ["core.export.markdown"] = {}, -- For Markdown export
    ["core.ui.calendar"] = {}, -- Loads the calendar module
    ["core.dirman"] = { -- Manage your directories
      config = {
        workspaces = {
          my_workspace = "~/neorg",
        }
      }
    },
  }
}

local last_health_check = 0
local check_interval = 10 * 60 -- 10 minutes in seconds

-- Autocommand to check Neorg health when opening .norg files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.norg",
    callback = function()
        local current_time = vim.fn.localtime() -- Use localtime for clarity
        
        -- Check if enough time has passed since the last health check
        if current_time - last_health_check >= check_interval then
            -- Run checkhealth neorg and capture the output
            local ok, output = pcall(vim.api.nvim_command_output, "checkhealth neorg")
            if not ok then
                -- Handle errors gracefully
                vim.api.nvim_echo({ { "Error running :checkhealth neorg", "ErrorMsg" } }, true, {})
                return
            end

            -- Split the output into lines
            local lines = vim.split(output, "\n")
            local issues = {}

            -- Collect lines containing warnings or errors
            for _, line in ipairs(lines) do
                if line:find("%[ERROR%]") or line:find("%[WARN%]") then
                    table.insert(issues, line)
                end
            end

            -- If there are issues, display them in the echo area
            if #issues > 0 then
                local msg = "Neorg health check reported issues:\n" .. table.concat(issues, "\n") .. "\nRun :checkhealth neorg for details."
                vim.api.nvim_echo({ { msg, "WarningMsg" } }, true, {})
            else
                vim.api.nvim_echo({ { "Neorg health check passed without issues.", "InfoMsg" } }, true, {})
            end

            -- Close the health check window if it exists
            vim.defer_fn(function()
                for _, win in pairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    local bufname = vim.api.nvim_buf_get_name(buf)

                    -- Debug: Print inspected buffer names
                    print("Inspecting buffer:", bufname)

                    -- If the buffer is the health check buffer
                    if bufname == "health://" then
                        print("Closing health check window...")
                        vim.api.nvim_win_close(win, true) -- Force close
                        break
                    end
                end
            end, 100) -- Add a short delay to ensure health check output is generated

            -- Update the last health check time
            last_health_check = current_time
        end
    end,
})

