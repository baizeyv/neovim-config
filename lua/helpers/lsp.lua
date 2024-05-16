local M = {}

--- create lsp on attach autocmds
---@param on_attach_func fun(client, buffer)
M.on_attach = function(on_attach_func)
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function (args)
            local buffer = args.buf ---@type number
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            on_attach_func(client, buffer)
        end
    })
end

return M