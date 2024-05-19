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
    for _, formatter in ipairs(M.resolve(buf)) do
        if #formatter.resolved > 0 then
            have = true
            lines[#lines + 1] = "\n# " .. formatter.name .. (formatter.active and " ***(Active)***" or "")
            for _, line in ipairs(formatter.resolved) do
                lines[#lines + 1] = ("- [%s] **%s**"):format(formatter.active and "x" or " ", line)
            end
        end
    end
    if not have then
        lines[#lines + 1] = "\n ***No formatters available for current buffer.***"
    end
    local notify = require("helpers.notify")
    notify[enabled and "info" or "warn"](table.concat(lines, "\n"), {
        title = "CustomFormat (" .. (enabled and "Enabled" or "Disabled") .. ")"
    })
end

---@param buf ? number
M.resolve = function(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    local have_primary = false
    return vim.tbl_map(function(formatter)
        local sources = formatter.sources(buf)
        local active = #sources > 0 and (not formatter.primary or not have_primary)
        have_primary = have_primary or (active and formatter.primary) or false
        return setmetatable({
            active = active,
            resolved = sources
        }, {
            __index = formatter
        })
    end, M.formatters)
end

---@param opts ? {force?:boolean, buf?:number}
M.format = function(opts)
    opts = opts or {}
    local buf = opts.buf or vim.api.nvim_get_current_buf()
    if not ((opts and opts.force) or M.enabled(buf)) then
        return
    end

    local done = false
    for _, formatter in ipairs(M.resolve(buf)) do
        if formatter.active then
            done = true
            require("helpers").try(function()
                return formatter.format(buf)
            end, {
                msg = "Formatter `" .. formatter.name .. "` **failed**"
            })
        end
    end

    if not done and opts and opts.force then
        require("helpers").notify.warn("No formatter available", { title = "Neovim-Formatter" })
    end
end

M.setup = function()
    -- Autoformat autocmd
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("CustomFormat", {}),
        callback = function(event)
            M.format({ buf = event.buf })
        end
    })
    -- Manual format
    vim.api.nvim_create_user_command(rc.manual_format_command, function()
        M.format({ force = true })
    end, { desc = "Format selection or current buffer" })
    -- Format info
    vim.api.nvim_create_user_command(rc.format_info_command, function()
        M.info()
    end, { desc = "Show info about the formatters for the current buffer" })
end

return M
