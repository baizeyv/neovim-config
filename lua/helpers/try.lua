return setmetatable({}, {
	---@param fn func
	---@param opts string|{msg:string, on_error:fun(msg)}
	__call = function(_, fn, opts)
		opts = type(opts) == "string" and { msg = opts } or opts or {}
		local msg = opts.msg
		-- error handle
		local error_handler = function(err)
			msg = (msg and (msg .. "\n\n") or "") .. err .. require("helpers.notify").pretty_trace()
			if opts.on_error then
				opts.on_error(msg)
			else
				vim.schedule(function()
					require("helpers.notify").error(msg)
				end)
			end
			return err
		end

		local ok, result = xpcall(fn, error_handler)
		return ok and result or nil
	end,
})
