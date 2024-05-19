local helper = require("helpers")

return {
	{
		"rcarriga/nvim-notify",
		keys = {
			{
				custom_keymaps.notify.dismiss,
				function()
					require("notify").dismiss({ silent = true, pending = true })
				end,
				desc = "Dismiss all notifications",
			},
		},
		opts = {
			stages = "fade_in_slide_out",
			timeout = 3000,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.5)
			end,
			render = "default",
			on_open = function(win)
				vim.api.nvim_win_set_config(win, { zindex = 100 })
			end,
			on_close = nil,
			minimum_width = 50,
			fps = 120,
			top_down = true,
			time_formats = {
				notification_history = "%FT%T",
				notification = "%T",
			},
			icons = {
				ERROR = "",
				WARN = "",
				INFO = "",
				DEBUG = "",
				TRACE = "✎",
			},
		},
		init = function()
			local ok = pcall(require, "noice")
			if not ok then
				helper.on_event("LoadCustomPlugins", function()
					vim.notify = require("notify")
				end)
			end
		end,
	},
}
