local M = {}

require("core.rc")

M.keymaps = require("core.keymaps")
M.autocmds = require("core.autocmds")
M.options = require("core.options")
M.lazy = require("core.plugin-loader")

M.setup = function ()
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePre" }, {
        once = true,
        pattern = "*",
        callback = function ()
            vim.api.nvim_exec_autocmds("User", { pattern = "CustomFile", modeline = false })
        end
    })

    -- autocmds can be loaded lazily when not opening a file
    local delay_autocmds = vim.fn.argc(-1) == 0
    if not delay_autocmds then
        M.load("autocmds")
    end

    M.load("options")

    local group = vim.api.nvim_create_augroup("WhoAreYou", { clear = true })
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "VeryLazy",
        callback = function ()
            if delay_autocmds then
                M.load("autocmds")
            end
            M.load("keymaps")
            vim.api.nvim_exec_autocmds("User", {
                pattern = "LoadCustomPlugins",
                modeline = false
            })
        end
    })
    
    M.load("lazy")
end

M.load = function(module)
    local function _load(mod)
        M[mod].setup()
    end
    _load(module)
    if vim.bo.filetype == "lazy" then
        vim.cmd([[do VimResized]])
    end
end

return M