local M = {}

---@class Formatter
---@field name string
---@field primary? boolean
---@field format fun(bufnr:number) format method
---@field sources fun(bufnr:number) formatter source array
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

---@param buf ? number
M.enabled = function(buf)
    buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
    local global_autoformat = rc.autoformat
    local buffer_autoformat = vim.b[buf].autoformat
    
    -- if the buffer has a local value, use it
    if buffer_autoformat ~= nil then
        return buffer_autoformat
    end
    
    -- otherwise use the global value if set, or true by default
    return global_autoformat == nil or global_autoformat
end

---@param buf ? number
M.info = function(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    local global_autoformat = rc.autoformat == nil or rc.autoformat
    local buffer_autoformat = vim.b[buf].autoformat
    local enabled = M.enabled(buf)
    local lines = {
        "# Status",
        ("- [%s] Global **%s**"):format(global_autoformat and "x" or " ", global_autoformat and "Enabled" or "Disabled"),
        ("- [%s] Buffer **%s**"):format(enabled and "x" or " ", buffer_autoformat == nil and "inherit" or buffer_autoformat and "Enabled" or "Disabled")
    }
    local have = false
end

return M