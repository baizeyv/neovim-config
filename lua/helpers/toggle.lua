local M = {}

local helper = require("helpers")

---toggle inlay hints
---@param buf? number
---@param value? boolean
M.inlay_hints = function(buf, value)
    local inlay_hints = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
    if type(inlay_hints) == "function" then
        inlay_hints(buf, value)
    elseif type(inlay_hints) == "table" and inlay_hints.enable then
        if value == nil then
            value = not inlay_hints.is_enabled(buf)
        end
        inlay_hints.enable(value, { bufnr = buf })
    end
end

M.autoformat = function(buf)
    if buf then
        vim.b.autoformat = not helper.format.enabled()
    else
        rc.autoformat = not helper.format.enabled()
        vim.b.autoformat = nil
    end
    -- TODO:
end

return M