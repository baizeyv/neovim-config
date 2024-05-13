local M = {}

M.set_map = function(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts)
end

M.del_map = function(mode, lhs, opts)
    vim.keymap.del(mode, lhs, opts)
end

M.set_leader = function(key)
    vim.g.mapleader = key
    vim.g.maplocalleader = key
    M.set_map({ "n", "v" }, key, "<NOP>")
end

return M