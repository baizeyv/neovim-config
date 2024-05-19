local M = {}

M.key = require("helpers.key")
M.toggle = require("helpers.toggle")
M.lsp = require("helpers.lsp")
M.notify = require("helpers.notify")
M.format = require("helpers.format")
M.try = require("helpers.try")

---@param event:string
---@param fn:func
M.on_event = function(event, fn)
	vim.api.nvim_create_autocmd("User", {
		pattern = event,
		callback = function()
			fn()
		end,
	})
end

M.opts = function(name)
	local plugin = require("lazy.core.config").spec.plugins[name]
	if not plugin then
		return {}
	end
	local Plugin = require("lazy.core.plugin")
	return Plugin.values(plugin, "opts", false)
end

M.is_list = function(t)
	local i = 0
	for _ in pairs(t) do
		i = i + 1
		if t[i] == nil then
			return false
		end
	end
	return true
end

M.can_merge = function(v)
	return type(v) == "table" and (vim.tbl_isempty(v) or not M.is_list(v))
end

M.merge = function(...)
	local ret = select(1, ...)
	if ret == vim.NIL then
		ret = nil
	end
	for i = 2, select("#", ...) do
		local values = select(i, ...)
		if M.can_merge(ret) and M.can_merge(value) then
			for k, v in pairs(values) do
				ret[k] = M.merge(ret[k], v)
			end
		elseif value == vim.NIL then
			ret = -nil
		elseif value ~= nil then
			ret = value
		end
	end
	return ret
end

return M
