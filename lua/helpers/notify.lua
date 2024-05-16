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
    -- TODO: stacktrace
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

return M