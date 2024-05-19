return {
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"onsails/lspkind.nvim",
				opts = {
					-- defines how annotations are shown
					-- default: symbol
					-- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
					mode = "symbol_text",

					max_width = 50,

					-- default symbol map
					-- can be either 'default' (requires nerd-fonts font) or
					-- 'codicons' for codicon preset (requires vscode-codicons font)
					--
					-- default: 'default'
					preset = "default",
					ellipsis_char = "...",
					show_labelDetails = true,

					-- override preset symbols
					--
					-- default: {}
					--[[
					symbol_map = {
						Text = "󰉿",
						Method = "󰆧",
						Function = "󰊕",
						Constructor = "",
						Field = "󰜢",
						Variable = "󰀫",
						Class = "󰠱",
						Interface = "",
						Module = "",
						Property = "󰜢",
						Unit = "󰑭",
						Value = "󰎠",
						Enum = "",
						Keyword = "󰌋",
						Snippet = "",
						Color = "󰏘",
						File = "󰈙",
						Reference = "󰈇",
						Folder = "󰉋",
						EnumMember = "",
						Constant = "󰏿",
						Struct = "󰙅",
						Event = "",
						Operator = "󰆕",
						TypeParameter = "",
					},]]
					symbol_map = rc.icons.kinds,
				},
				config = function(_, opts)
					require("lspkind").init(opts)
				end,
			},
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			{
				"hrsh7th/cmp-cmdline",
				keys = { ":", "/", "?" },
			},
			"rafamadriz/friendly-snippets",
			{
				"garymjr/nvim-snippets",
				keys = {
					{
						custom_keymaps.cmp.snippet_next,
						function()
							if vim.snippet.active({ direction = 1 }) then
								vim.schedule(function()
									vim.snippet.jump(1)
								end)
								return
							end
							return "<Tab>"
						end,
						expr = true,
						silent = true,
						mode = "i",
					},
					{
						custom_keymaps.cmp.snippet_next,
						function()
							vim.schedule(function()
								vim.snippet.jump(1)
							end)
						end,
						expr = true,
						silent = true,
						mode = "s",
					},
					{
						custom_keymaps.cmp.snippet_prev,
						function()
							if vim.snippet.active({ direction = -1 }) then
								vim.schedule(function()
									vim.snippet.jump(-1)
								end)
								return
							end
							return "<S-Tab>"
						end,
						expr = true,
						silent = true,
						mode = { "i", "s" },
					},
				},
				opts = {
					friendly_snippets = true,
					search_paths = {
						vim.fn.stdpath("config") .. "/snippets",
					},
				},
			},
		},
		opts = function()
			vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
			local cmp = require("cmp")
			local defaults = require("cmp.config.default")()
			local WIDE_HEIGHT = 40
			local types = require("cmp.types")

			return {
				performance = {
					debounce = 60,
					throttle = 30,
					fetching_timeout = 500,
					confirm_resolve_timeout = 80,
					async_budget = 1,
					max_view_entries = 200,
				},
				preselect = types.cmp.PreselectMode.Item,
				completion = {
					autocomplete = {
						types.cmp.TriggerEvent.TextChanged,
					},
					completeopt = "menu,menuone,noinsert",
					keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
					keyword_length = 1,
				},
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
				window = {
					completion = {
						border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
						-- border = "rounded",
						winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
						winblend = vim.o.pumblend,
						scrolloff = 0,
						col_offset = 0,
						side_padding = 1,
						scrollbar = true,
					},
					documentation = {
						max_height = math.floor(WIDE_HEIGHT * (WIDE_HEIGHT / vim.o.lines)) * 3,
						max_width = math.floor((WIDE_HEIGHT * 2) * (vim.o.columns / (WIDE_HEIGHT * 2 * 16 / 9))) * 2,
						border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
						-- border = "rounded",
						winhighlight = "FloatBorder:NormalFloat",
						winblend = vim.o.pumblend,
					},
				},
				mapping = cmp.mapping.preset.insert({
					[custom_keymaps.cmp.select_next] = cmp.mapping.select_next_item({
						behavior = cmp.SelectBehavior.Insert,
					}),
					[custom_keymaps.cmp.select_prev] = cmp.mapping.select_prev_item({
						behavior = cmp.SelectBehavior.Insert,
					}),
					[custom_keymaps.cmp.scroll_down] = cmp.mapping.scroll_docs(4),
					[custom_keymaps.cmp.scroll_up] = cmp.mapping.scroll_docs(-4),
					[custom_keymaps.cmp.complete] = cmp.mapping.complete(),
					[custom_keymaps.cmp.abort] = cmp.mapping.abort(),
					[custom_keymaps.cmp.confirm] = cmp.mapping.confirm({ select = true }),
					[custom_keymaps.cmp.confirm_replace] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
					[custom_keymaps.cmp.newline] = function(fallback)
						cmp.abort()
						fallback()
					end,
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "snippets" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}),
				formatting = {
					expandable_indicator = true,
					fields = { "kind", "abbr", "menu" },
					format = function(entry, item)
						local mode = vim.api.nvim_get_mode().mode
						if mode == "c" then
							return item
						end
						local kind_opts = require("helpers").opts("lspkind.nvim")
						local kind = require("lspkind").cmp_format(kind_opts)(entry, item)
						local strings = vim.split(kind.kind, "%s", { trimempty = true })
						kind.kind = " " .. (strings[1] or "") .. " "
						kind.menu = "    (" .. (strings[3] or "") .. ")"
						return kind
					end,
				},
				view = {
					entries = {
						name = "custom",
						selection_order = "top_down",
						follow_cursor = true,
					},
					docs = {
						auto_open = true,
					},
				},
				enabled = function()
					-- disable completion in comments
					local context = require("cmp.config.context")
					-- keep command mode completion enabled when cursor is in a comment
					if vim.api.nvim_get_mode().mode == "c" then
						return true
					else
						return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
					end
				end,
				experimental = {
					ghost_text = {
						hl_group = "CmpGhostText",
					},
				},
				sorting = defaults.sorting,
			}
		end,
		config = function(_, opts)
			for _, source in ipairs(opts.sources) do
				source.group_index = source.group_index or 1
			end
			local cmp = require("cmp")
			local ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
			if ok then
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			end
			cmp.setup(opts)

			local cmdline_mapping = {
				[custom_keymaps.cmp.select_next] = {
					c = function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end,
				},
				[custom_keymaps.cmp.select_prev] = {
					c = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end,
				},
				[custom_keymaps.cmp.newline] = {
					c = function(fallback)
						if cmp.visible() then
							cmp.confirm({ select = true })
						else
							fallback()
						end
					end,
				},
				[custom_keymaps.cmp.complete] = {
					c = function(fallback)
						cmp.complete()
					end,
				},
				[custom_keymaps.cmp.abort] = {
					c = function(fallback)
						if cmp.visible() then
							cmp.abort()
						else
							fallback()
						end
					end,
				},
			}

			-- `/` cmdline setup.
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(cmdline_mapping),
				view = {
					entries = {
						name = "wildmenu",
						separator = " | ",
					},
				},
				sources = {
					{ name = "buffer" },
				},
			})
			-- `:` cmdline setup.
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(cmdline_mapping),
				view = {
					entries = {
						name = "wildmenu",
						separator = " | ",
					},
				},
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{
						name = "cmdline",
						option = {
							ignore_cmds = { "Man", "!" },
						},
					},
				}),
				matching = {
					disallow_symbol_noprefix_matching = false,
				},
			})
		end,
	},
}
