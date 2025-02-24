return {
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {
			dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"), -- directory where session files are saved
			options = { "buffers", "curdir", "tabpages", "winsize" }, -- sessionoptions used for saving
			pre_save = nil, -- a function to call before saving the session
			post_save = nil, -- a function to call after saving the session
			save_empty = false, -- don't save if there are no open file buffers
			pre_load = nil, -- a function to call before loading the session
			post_load = nil, -- a function to call after loading the session
		},
		keys = {
			{
				custom_keymaps.session.restore,
				function()
					require("persistence").load()
				end,
				desc = "Restore Session",
			},
			{
				custom_keymaps.session.restore_last,
				function()
					require("persistence").load({ last = true })
				end,
				desc = "Restore Last Session",
			},
			{
				custom_keymaps.session.stop,
				function()
					require("persistence").stop()
				end,
				desc = "Don't Save Current Session",
			},
		},
	},
}
