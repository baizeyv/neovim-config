local helper = require("helpers")

local format_opts = {
	timeout_ms = 3000,
	async = false,
	quiet = false,
	lsp_fallback = true,
}

return {
	{
		"stevearc/conform.nvim",
		dependencies = {
			"mason.nvim",
		},
		cmd = "ConformInfo",
		init = function()
			helper.on_event("LoadCustomPlugins", function()
				helper.format.register({
					name = "conform.nvim",
					priority = 100,
					primary = true,
					format = function(buf)
						require("conform").format(helper.merge({}, format_opts, { bufnr = buf }))
					end,
					sources = function(buf)
						local ret = require("conform").list_formatters(buf)
						return vim.tbl_map(function(v)
							return v.name
						end, ret)
					end,
				})
			end)
		end,
		keys = {
			{
				custom_keymaps.format,
				function()
					require("conform").format({ formatters = { "injected" }, timeout_ms = format_opts.timeout_ms })
				end,
				mode = { "n", "v" },
				desc = "Format Injected Langs",
			},
		},
		opts = {
			custom_format_opts = format_opts,
			-- Map of filetype to formatters
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				go = { "goimports", "gofmt" },
				-- Use a sub-list to run only the first available formatter
				javascript = { { "prettierd", "prettier" } },
				-- You can use a function here to determine the formatters dynamically
				python = function(bufnr)
					if require("conform").get_formatter_info("ruff_format", bufnr).available then
						return { "ruff_format" }
					else
						return { "isort", "black" }
					end
				end,
				fish = { "fish_indent" },
				sh = { "shfmt" },
				-- Use the "*" filetype to run formatters on all filetypes.
				["*"] = { "codespell" },
				-- Use the "_" filetype to run formatters on filetypes that don't
				-- have other formatters configured.
				["_"] = { "trim_whitespace" },
			},
			-- If this is set, Conform will run the formatter on save.
			-- It will pass the table to conform.format().
			-- This can also be a function that returns the table.
			--[[
            format_on_save = {
                -- I recommend these options. See :help conform.format for details.
                lsp_fallback = true,
                timeout_ms = 500,
            },
            -- If this is set, Conform will run the formatter asynchronously after save.
            -- It will pass the table to conform.format().
            -- This can also be a function that returns the table.
            format_after_save = {
                lsp_fallback = true,
            },
            ]]
			--
			-- Set the log level. Use `:ConformInfo` to see the location of the log file.
			log_level = vim.log.levels.ERROR,
			-- Conform will notify you when a formatter errors
			notify_on_error = true,
			-- Custom formatters and changes to built-in formatters
			formatters = {
				injected = {
					options = { ignore_errors = true },
				},
				--[[
                my_formatter = {
                    -- This can be a string or a function that returns a string.
                    -- When defining a new formatter, this is the only field that is required
                    command = "my_cmd",
                    -- A list of strings, or a function that returns a list of strings
                    -- Return a single string instead of a list to run the command in a shell
                    args = { "--stdin-from-filename", "$FILENAME" },
                    -- If the formatter supports range formatting, create the range arguments here
                    range_args = function(self, ctx)
                        return { "--line-start", ctx.range.start[1], "--line-end", ctx.range["end"][1] }
                    end,
                    -- Send file contents to stdin, read new contents from stdout (default true)
                    -- When false, will create a temp file (will appear in "$FILENAME" args). The temp
                    -- file is assumed to be modified in-place by the format command.
                    stdin = true,
                    -- A function that calculates the directory to run the command in
                    cwd = require("conform.util").root_file({ ".editorconfig", "package.json" }),
                    -- When cwd is not found, don't run the formatter (default false)
                    require_cwd = true,
                    -- When stdin=false, use this template to generate the temporary file that gets formatted
                    tmpfile_format = ".conform.$RANDOM.$FILENAME",
                    -- When returns false, the formatter will not be used
                    condition = function(self, ctx)
                        return vim.fs.basename(ctx.filename) ~= "README.md"
                    end,
                    -- Exit codes that indicate success (default { 0 })
                    exit_codes = { 0, 1 },
                    -- Environment variables. This can also be a function that returns a table.
                    env = {
                        VAR = "value",
                    },
                    -- Set to false to disable merging the config with the base definition
                    inherit = true,
                    -- When inherit = true, add these additional arguments to the command.
                    -- This can also be a function, like args
                    prepend_args = { "--use-tabs" }, -- 之前用的是 extra_args
                },
                -- These can also be a function that returns the formatter
                other_formatter = function(bufnr)
                    return {
                        command = "my_cmd",
                    }
                end,]]
				--
			},
		},
		config = function(_, opts)
			for name, formatter in pairs(opts.formatters or {}) do
				if type(formatter) == "table" then
					if formatter.extra_args then
						formatter.prepend_args = formatter.extra_args
						helper.notify.deprecate(
							("opts.formatters.%s.extra_args"):format(name),
							("opts.formatters.%s.prepend_args"):format(name)
						)
					end
				end
			end

			for _, key in ipairs({ "format_on_save", "format_after_save" }) do
				if opts[key] then
					helper.notify.warn(
						("Don't set `opts.%s` for `conform.nvim`.\n**NeoVim** will use the conform formatter automatically"):format(
							key
						)
					)
					---@diagnostic disable-next-line: no-unknown
					opts[key] = nil
				end
			end
			require("conform").setup(opts)
		end,
	},
}
