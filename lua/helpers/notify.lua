local M = {}

---@class NotifyOpts
---@field lang? string language name -> e.g. markdown -> lua
---@field title? string notify title
---@field once? boolean whether is only execute once
---@field level? number notify level
---@field stacktrace? boolean whether is trace the stack info
---@field stacklevel? number stack trace level
---@field timeout? number notify shown time

---show a special notify
---@param msg string
---@param opts NotifyOpts
M.notify = function (msg, opts)
    if vim.in_fast_event() then
        return vim.schedule(function ()
            M.notify(msg, opts)
        end)
    end
    ----------------------------------------
    opts = opts or {}
    if type(msg) == "table" then
        msg = table.concat(vim.tbl_filter(function (line)
            return line or false -- filter the empty info
        end, msg), "\n")
    end
    ----------------------------------------
    if opts.stacktrace then
        msg = msg .. M.pretty_trace({ level = opts.stacklevel or 2 })
    end
    ----------------------------------------
    local lang = opts.lang or "markdown"
    local notify = opts.once and vim.notify_once or vim.notify
    local notify_level = opts.level or vim.log.levels.INFO
    notify(msg, notify_level, {
        title = opts.title or rc.custom_name,
        timeout = opts.timeout or 3000,
        on_open = function (win)
            local ok = pcall(function ()
                vim.treesitter.language.add("markdown")
            end)
            if not ok then
                pcall(require, "nvim-treesitter")
            end
            vim.wo[win].conceallevel = 3 -- hide blank stand symbol
            vim.wo[win].concealcursor = "" -- hide cursor
            vim.wo[win].spell = false -- close the spell check
            local buf = vim.api.nvim_win_get_buf(win) -- gain the notify buffer
            if not pcall(vim.treesitter.start, buf, lang) then
                vim.bo[buf].filetype = lang
                vim.bo[buf].syntax = lang
            end
        end,
        on_close = function ()
            -- do nothing
        end
    })
end

---@param opts? {level?:number}
M.pretty_trace = function(opts)
    opts = opts or {}
    local trace = {}
    local level = opts.level or 2
    while true do
        local info = debug.getinfo(level, "Sln")
        if not info then
            break
        end
        if info.what ~= "C" then
            local source = info.source:sub(2)
            if source:find(rc.lazy_root, 1, true) == 1 then
                source = source:sub(#rc.lazy_root + 1)
            end
            source = vim.fn.fnamemodify(source, ":p:~:.")
            local line = "  - " .. source .. ":" .. info.currentline
            if info.name then
                line = line .. " _in_ **" .. info.name .. "**"
            end
            table.insert(trace, line)
        end
        level = level + 1
    end
    return #trace > 0 and ("\n\n# stacktrack:\n" .. table.concat(trace, "\n")) or ""
end

M.info = function(msg, opts)
    opts = opts or {}
    opts.level = vim.log.levels.INFO
    M.notify(msg, opts)
end

M.warn = function(msg, opts)
    opts = opts or {}
    opts.level = vim.log.levels.WARN
    M.notify(msg, opts)
end

M.error = function(msg, opts)
    opts = opts or {}
    opts.level = vim.log.levels.ERROR
    M.notify(msg, opts)
end

return M
