local M = {}

--- create lsp on attach autocmds
---@param on_attach_func fun(client, buffer)
M.on_attach = function(on_attach_func)
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local buffer = args.buf ---@type number
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			on_attach_func(client, buffer)
		end,
	})
end

---@param opts? CustomFormatter|{filter?: (string|lsp.Client.filter)}
M.formatter = function(opts)
	opts = opts or {}
	local filter = opts.filter or {}
	filter = type(filter) == "string" and { name = filter } or filter
	local ret = {
		name = "LSP",
		primary = true,
		priority = 1,
		format = function(buf)
			M.format(require("helpers").merge({}, filter, { bufnr = buf }))
		end,
		sources = function(buf)
			local clients = M.get_clients(require("helpers").merge({}, filter, { bufnr = buf }))
			local ret = vim.tbl_filter(function(client)
				return client.supports_method("textDocument/formatting")
					or client.supports_method("textDocument/rangeFormatting")
			end, clients)
			return vim.tbl_map(function(client)
				return client.name
			end, ret)
		end,
	}
	return require("helpers").merge(ret, opts) --CustomFormatter
end

M.format = function(opts)
	local helper = require("helpers")
	opts = vim.tbl_deep_extend(
		"force",
		{},
		opts or {},
		helper.opts("nvim-lspconfig").custom_format_opts or {},
		helper.opts("conform.nvim").custom_format_opts or {}
	)
	local ok, conform = pcall(require, "conform")
	if ok then
		opts.formatters = {}
		conform.format(opts)
	else
		vim.lsp.buf.format(opts)
	end
end

---@param opts? lsp.Client.filter
M.get_clients = function(opts)
	local ret = {}
	if vim.lsp.get_clients then
		ret = vim.lsp.get_clients(opts)
	else
		ret = vim.lsp.get_active_clients(opts)
		if opts and opts.method then
			ret = vim.tbl_filter(function(client)
				return client.supports_method(opts.method, { bufnr = opts.bufnr })
			end, ret)
		end
	end
	return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

return M
