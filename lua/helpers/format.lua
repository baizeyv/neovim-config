local M = {}

---@class Formatter
---@field name string
---@field primary? boolean
---@field format fun(bufnr:number) format method
---@field sources fun(bufnr:number) formatter name array
---@field priority number

---@type Formatter[]
M.formatters = {}

---registry the specific formatter
---@param formatter Formatter
M.register = function (formatter)
    M.formatters[#M.formatters+1] = formatter
    table.sort(M.formatters, function (a, b)
        return a.priority > b.priority
    end)
end

---vim option -> formatexpr
M.formatexpr = function ()
    local ok, ins = pcall(require, "conform.nvim");
    if ok then
        return ins.formatexpr()
    end
    return vim.lsp.formatexpr({ timeout_ms = 3000 })
end

return M