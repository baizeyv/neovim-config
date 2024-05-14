local M = {}

M.setup = function ()
    vim.o.guifont = "RecMonoDuotone Nerd Font:h11"
    if vim.g.neovide then
        vim.g.neovide_transparency = 0.85
        vim.g.neovide_hide_mouse_when_typing = true
        vim.g.neovide_fullscreen = true
        vim.g.neovide_remember_window_size = true
        vim.g.neovide_profiler = false
        vim.g.neovide_cursor_vfx_mode = "wireframe"
    end
    
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
end

return M