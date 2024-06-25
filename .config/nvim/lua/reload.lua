vim.cmd('command! ReloadConfig lua ReloadConfig()')
-- lua/reload.lua
-- function _G.ReloadConfig()
--     for name,_ in pairs(package.loaded) do
--         if name:match('^user') and not name:match('nvim') then
--             package.loaded[name] = nil
--         end
--     end
--     dofile(vim.env.MYVIMRC)
-- end
-- lua/reload.lua
function _G.ReloadConfig()
    local modules_to_reload = {
        'plugins',
        'settings',
        'keymaps',
        'lsp'
    }

    for _, module in ipairs(modules_to_reload) do
        package.loaded[module] = nil
    end

    dofile(vim.env.MYVIMRC)
end


