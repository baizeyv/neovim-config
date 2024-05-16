local M = {}

local function augroup(name)
    vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

M.setup = function ()
    -- highlight on yank
    vim.api.nvim_create_autocmd("TextYankPost", {
        group = augroup("highlight_yank"),
        callback = function ()
            vim.highlight.on_yank({
                higroup = "IncSearch",
                timeout = 300
            })
        end
    })
end

return M