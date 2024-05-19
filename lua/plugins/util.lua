return {
	{ -- NOTE: A library used by other plugins (lua enhancement plugin)
		"nvim-lua/plenary.nvim",
	},
	{ -- NOTE: move down or up quickly (smooth accelerated motion)
		"rainbowhxch/accelerated-jk.nvim",
		event = "User CustomKeymaps",
		opts = {
			mode = "time_driven",
			enable_deceleration = false,
			acceleration_motions = {},
			acceleration_limit = 150,
			acceleration_table = { 7, 12, 17, 21, 24, 26, 28, 30 },
			-- when enable_deceleration = true
			deceleration_table = { { 150, 9999 } },
		},
		config = function(_, opts)
			require("accelerated-jk").setup(opts)
			local map = custom_keymaps.map
			local jk = require("accelerated-jk")

			local down_func = function()
				if vim.v.count == 0 then
					jk.move_to("gj")
				else
					jk.move_to("j")
				end
			end
			local up_func = function()
				if vim.v.count == 0 then
					jk.move_to("gk")
				else
					jk.move_to("k")
				end
			end
			local quick_down_func = function()
				if vim.v.count == 0 then
					for i = 1, 5 do
						jk.move_to("gj")
					end
				else
					for i = 1, 5 do
						jk.move_to("j")
					end
				end
			end
			local quick_up_func = function()
				if vim.v.count == 0 then
					for i = 1, 5 do
						jk.move_to("gk")
					end
				else
					for i = 1, 5 do
						jk.move_to("k")
					end
				end
			end

			map({ "n", "v", "x" }, custom_keymaps.accelerated.down, down_func, { silent = true, desc = "[Move] Down" })
			map({ "n", "v", "x" }, custom_keymaps.accelerated.up, up_func, { silent = true, desc = "[Move] Up" })
			map(
				{ "n", "v", "x" },
				custom_keymaps.accelerated.quick_up,
				quick_up_func,
				{ silent = true, desc = "[Move] Up Quickly" }
			)
			map(
				{ "n", "v", "x" },
				custom_keymaps.accelerated.quick_down,
				quick_down_func,
				{ silent = true, desc = "[Move] Down Quickly" }
			)
		end,
	},
	{ -- NOTE: <C-a> and <C-x> enhancement util
		"nat-418/boole.nvim",
		event = "User CustomFile",
		opts = {
			mappings = {
				increment = custom_keymaps.boole.increment,
				decrement = custom_keymaps.boole.decrement,
			},
			-- User defined loops
			additions = {
				{ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
			},
			allow_caps_additions = {
				{ "true", "false" },
				{ "yes", "no" },
				{ "enable", "disable" },
				-- for example:
				-- enable -> disable
				-- Enable -> Disable
				-- ENABLE -> DISABLE
			},
		},
	},
}

