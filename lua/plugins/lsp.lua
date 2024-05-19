local helper = require("helpers")

local neoconf_opts = {
	-- name of the local settings files
	local_settings = ".neoconf.json",
	-- name of the global settings file in your Neovim config directory
	global_settings = "neoconf.json",
	-- import existing settings from other plugins
	import = {
		vscode = true, -- local .vscode/settings.json
		coc = true, -- global/local coc-settings.json
		nlsp = true, -- global/local nlsp-settings.nvim json settings
	},
	-- send new configuration to lsp clients when changing json settings
	live_reload = true,
	-- set the filetype to jsonc for settings files, so you can use comments
	-- make sure you have the jsonc treesitter parser installed!
	filetype_jsonc = true,
	plugins = {
		-- configures lsp clients with settings in the following order:
		-- - lua settings passed in lspconfig setup
		-- - global json settings
		-- - local json settings
		lspconfig = {
			enabled = true,
		},
		-- configures jsonls to get completion in .nvim.settings.json files
		jsonls = {
			enabled = true,
			-- only show completion in json settings for configured lsp servers
			configured_servers_only = true,
		},
		-- configures lua_ls to get completion of lspconfig server settings
		lua_ls = {
			-- by default, lua_ls annotations are only enabled in your neovim config directory
			enabled_for_neovim_config = true,
			-- explicitely enable adding annotations. Mostly relevant to put in your local .nvim.settings.json file
			enabled = false,
		},
	},
}

----------------------------------------------------------------------------------------------

local _keys = nil

local get_lsp_keymaps = function()
	if _keys then
		return _keys
	end
	_keys = {
		{
			custom_keymaps.lsp.goto_definitions,
			function()
				require("telescope.builtin").lsp_definitions({ reuse_win = true })
			end,
			desc = "Goto Definition",
			has = "definition",
		},
		{
			custom_keymaps.lsp.goto_references,
			"<CMD>Telescope lsp_references<CR>",
			desc = "References",
		},
		{
			custom_keymaps.lsp.goto_declaration,
			vim.lsp.buf.declaration,
			desc = "Goto Declaration",
		},
		{
			custom_keymaps.lsp.goto_implementations,
			function()
				require("telescope.builtin").lsp_implementations({ reuse_win = true })
			end,
			desc = "Goto Implementation",
		},
		{
			custom_keymaps.lsp.goto_type_definitions,
			function()
				require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
			end,
			desc = "Goto Type Definition",
		},
		{
			custom_keymaps.lsp.hover,
			vim.lsp.buf.hover,
			desc = "Hover",
		},
		{
			custom_keymaps.lsp.normal_signature_help,
			vim.lsp.buf.signature_help,
			desc = "Signature Help",
			has = "signatureHelp",
		},
		{
			custom_keymaps.lsp.insert_signature_help,
			vim.lsp.buf.signature_help,
			mode = "i",
			desc = "Signature Help",
			has = "signatureHelp",
		},
		{
			custom_keymaps.lsp.code_action,
			vim.lsp.buf.code_action,
			desc = "Code Action",
			mode = { "n", "v" },
			has = "codeAction",
		},
		{
			custom_keymaps.lsp.source_action,
			function()
				vim.lsp.buf.code_action({
					context = {
						only = {
							"source",
						},
						diagnostics = {},
					},
				})
			end,
			desc = "Source Action",
			has = "codeAction",
		},
		{
			custom_keymaps.lsp.codelens,
			vim.lsp.codelens.run,
			desc = "Run Codelens",
			mode = { "n", "v" },
			has = "codeLens",
		},
		{
			custom_keymaps.lsp.codelens_refresh,
			vim.lsp.codelens.refresh,
			desc = "Refresh & Display Codelens",
			mode = "n",
			has = "codeLens",
		},
	}
	local ok, inc_rename = pcall(require, "inc_rename")
	if ok then
		_keys[#_keys + 1] = {
			custom_keymaps.lsp.rename,
			function()
				return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
			end,
			expr = true,
			desc = "Rename",
			has = "rename",
		}
	else
		_keys[#_keys + 1] = {
			custom_keymaps.lsp.rename,
			vim.lsp.buf.rename,
			desc = "Rename",
			has = "rename",
		}
	end
	return _keys
end

local function has_method(buffer, method)
	method = method:find("/") and method or "textDocument/" .. method
	local clients = helper.lsp.get_clients({ bufnr = buffer })
	for _, client in ipairs(clients) do
		if client.supports_method(method) then
			return true
		end
	end
	return false
end

local function keymap_resolve(buffer)
	local Keys = require("lazy.core.handler.keys")
	if not Keys.resolve then
		return {}
	end
	local spec = get_lsp_keymaps()
	local opts = helper.opts("nvim-lspconfig")
	local clients = helper.lsp.get_clients({ bufnr = buffer })
	for _, client in ipairs(clients) do
		local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
		vim.list_extend(spec, maps)
	end
	return Keys.resolve(spec)
end

local function keymap_on_attach(_, buffer)
	local Keys = require("lazy.core.handler.keys")
	local keymaps = keymap_resolve(buffer)

	for _, keys in pairs(keymaps) do
		if not keys.has or has_method(buffer, keys.has) then
			local opts = Keys.opts(keys)
			opts.has = nil
			opts.silent = opts.silent ~= false
			opts.buffer = buffer
			custom_keymaps.map(keys.mode or "n", keys.lhs, keys.rhs, opts)
		end
	end
end

----------------------------------------------------------------------------------------------

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"folke/neoconf.nvim",
			"folke/neodev.nvim",
			"mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		opts = {
			-- options for vim.lsp.buf.format (my custom options)
			custom_format_opts = {
				formatting_options = nil,
				timeoout_ms = nil,
			},

			-- options for vim.diagnostic.config()
			diagnostics = {
				underline = true,
				update_in_insert = true,
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "●",
				},
				severity_sort = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = rc.icons.diagnostics.Error,
						[vim.diagnostic.severity.WARN] = rc.icons.diagnostics.Warn,
						[vim.diagnostic.severity.HINT] = rc.icons.diagnostics.Hint,
						[vim.diagnostic.severity.INFO] = rc.icons.diagnostics.Info,
					},
				},
			},

			-- enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
			-- be aware that you also will need to properly configure your LSP server to provide the inlay hints.
			inlay_hints = {
				enable = true,
			},
			-- enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
			-- be aware that you also will need to properly configure your LSP server to provide the code lenses.
			codelens = {
				enable = true,
			},
			capabilities = {},
			servers = {
				lua_ls = {
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							codeLens = {
								enable = true,
							},
							completion = {
								callSnippet = "Replace",
							},
							doc = {
								privateName = { "^_" },
							},
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
						},
					},
				},
			},
			setup = {},
		},
		config = function(_, opts)
			local ok, neoconf = pcall(require, "neoconf")
			if ok then
				neoconf.setup(neoconf_opts)
			end

			-- setup autoformat
			helper.format.register(helper.lsp.formatter())

			-- setup keymaps
			helper.lsp.on_attach(function(client, buffer)
				keymap_on_attach(client, buffer)
			end)

			local register_capability = vim.lsp.handlers["client/registerCapability"]

			vim.lsp.handlers["client/registerCapabielity"] = function(err, res, ctx)
				local ret = register_capability(err, res, ctx)
				local client = vim.lsp.get_client_by_id(ctx.client_id)
				local buffer = vim.api.nvim_get_current_buf()
				keymap_on_attach(client, buffer)
				return ret
			end

			if type(opts.diagnostics.signs) ~= "boolean" then
				for severity, icon in pairs(opts.diagnostics.signs.text) do
					local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
					name = "DiagnosticSign" .. name
					vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
				end
			end

			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			-- inlay hints
			if opts.inlay_hints.enable then
				helper.lsp.on_attach(function(client, buffer)
					if client.supports_method("textDocument/inlayHint") then
						helper.toggle.inlay_hints(buffer, true)
					end
				end)
			end

			-- code lens
			if opts.codelens.enable then
				helper.lsp.on_attach(function(client, buffer)
					if client.supports_method("textDocument/codeLens") then
						vim.lsp.codelens.refresh()
						-- autocmd BufEnter, CursorHold, InsertLeave <buffer> lua vim.lsp.codelens.refresh()
						vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
							buffer = buffer,
							callback = vim.lsp.codelens.refresh,
						})
					end
				end)
			end

			-- TODO:
			local servers = opts.servers
			local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				has_cmp and cmp_nvim_lsp.default_capabilities() or {},
				opts.capabilities or {}
			)

			local function setup(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
				}, servers[server] or {})
				if opts.setup[server] then
					if opts.setup[server](server, server_opts) then
						return
					end
				elseif opts.setup["*"] then
					if opts.setup["*"](server, server_opts) then
						return
					end
				end
				require("lspconfig")[server].setup(server_opts)
			end

			-- get all the servers that are available through mason-lspconfig
			local have_mason, mlsp = pcall(require, "mason-lspconfig")
			local all_mlsp_servers = {}
			if have_mason then
				all_mlsp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
			end

			local ensure_installed = {}
			for server, server_opts in pairs(servers) do
				if server_opts then
					server_opts = server_opts == true and {} or server_opts
					if server_opts.mason == false or not vim.tbl_contains(all_mlsp_servers, server) then
						setup(server)
					elseif server_opts.enabled ~= false then
						ensure_installed[#ensure_installed + 1] = server
					end
				end
			end

			if have_mason then
				mlsp.setup({
					ensure_installed = vim.tbl_deep_extend(
						"force",
						ensure_installed,
						helper.opts("mason-lspconfig.nvim").ensure_installed or {}
					),
					handlers = { setup },
					automatic_installation = true,
				})
			end
		end,
	},
	{
		"williamboman/mason.nvim",
		cmd = {
			"Mason",
			"MasonUpdate",
			"MasonInstall",
			"MasonUninstall",
			"MasonUninstallAll",
			"MasonLog",
		},
		build = ":MasonUpdate",
		opts = {
			ensure_installed = { "stylua", "shfmt" },
			---@since 1.0.0
			-- The directory in which to install packages.
			-- install_root_dir = require("mason-core.path").concat { vim.fn.stdpath "data", "mason" },
			install_root_dir = vim.fn.stdpath("data") .. "/mason",

			---@since 1.0.0
			-- Where Mason should put its bin location in your PATH. Can be one of:
			-- - "prepend" (default, Mason's bin location is put first in PATH)
			-- - "append" (Mason's bin location is put at the end of PATH)
			-- - "skip" (doesn't modify PATH)
			---@type '"prepend"' | '"append"' | '"skip"'
			PATH = "prepend",

			---@since 1.0.0
			-- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
			-- debugging issues with package installations.
			log_level = vim.log.levels.INFO,

			---@since 1.0.0
			-- Limit for the maximum amount of packages to be installed at the same time. Once this limit is reached, any further
			-- packages that are requested to be installed will be put in a queue.
			max_concurrent_installers = 4,

			---@since 1.0.0
			-- [Advanced setting]
			-- The registries to source packages from. Accepts multiple entries. Should a package with the same name exist in
			-- multiple registries, the registry listed first will be used.
			registries = {
				"github:mason-org/mason-registry",
			},

			---@since 1.0.0
			-- The provider implementations to use for resolving supplementary package metadata (e.g., all available versions).
			-- Accepts multiple entries, where later entries will be used as fallback should prior providers fail.
			-- Builtin providers are:
			--   - mason.providers.registry-api  - uses the https://api.mason-registry.dev API
			--   - mason.providers.client        - uses only client-side tooling to resolve metadata
			providers = {
				"mason.providers.registry-api",
				"mason.providers.client",
			},

			github = {
				---@since 1.0.0
				-- The template URL to use when downloading assets from GitHub.
				-- The placeholders are the following (in order):
				-- 1. The repository (e.g. "rust-lang/rust-analyzer")
				-- 2. The release version (e.g. "v0.3.0")
				-- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
				download_url_template = "https://github.com/%s/releases/download/%s/%s",
			},

			pip = {
				---@since 1.0.0
				-- Whether to upgrade pip to the latest version in the virtual environment before installing packages.
				upgrade_pip = false,

				---@since 1.0.0
				-- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
				-- and is not recommended.
				--
				-- Example: { "--proxy", "https://proxyserver" }
				install_args = {},
			},

			ui = {
				---@since 1.0.0
				-- Whether to automatically check for new versions when opening the :Mason window.
				check_outdated_packages_on_open = true,

				---@since 1.0.0
				-- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
				border = "none",

				---@since 1.0.0
				-- Width of the window. Accepts:
				-- - Integer greater than 1 for fixed width.
				-- - Float in the range of 0-1 for a percentage of screen width.
				width = 0.8,

				---@since 1.0.0
				-- Height of the window. Accepts:
				-- - Integer greater than 1 for fixed height.
				-- - Float in the range of 0-1 for a percentage of screen height.
				height = 0.9,

				icons = {
					---@since 1.0.0
					-- The list icon to use for installed packages.
					package_installed = "◍",
					---@since 1.0.0
					-- The list icon to use for packages that are installing, or queued for installation.
					package_pending = "◍",
					---@since 1.0.0
					-- The list icon to use for packages that are not installed.
					package_uninstalled = "◍",
				},

				keymaps = {
					---@since 1.0.0
					-- Keymap to expand a package
					toggle_package_expand = "<CR>",
					---@since 1.0.0
					-- Keymap to install the package under the current cursor position
					install_package = "t",
					---@since 1.0.0
					-- Keymap to reinstall/update the package under the current cursor position
					update_package = "a",
					---@since 1.0.0
					-- Keymap to check for new version for the package under the current cursor position
					check_package_version = "c",
					---@since 1.0.0
					-- Keymap to update all installed packages
					update_all_packages = "A",
					---@since 1.0.0
					-- Keymap to check which installed packages are outdated
					check_outdated_packages = "C",
					---@since 1.0.0
					-- Keymap to uninstall a package
					uninstall_package = "X",
					---@since 1.0.0
					-- Keymap to cancel a package installation
					cancel_installation = "<C-c>",
					---@since 1.0.0
					-- Keymap to apply language filter
					apply_language_filter = "<C-f>",
					---@since 1.1.0
					-- Keymap to toggle viewing package installation log
					toggle_package_install_log = "<CR>",
					---@since 1.8.0
					-- Keymap to toggle the help view
					toggle_help = "?",
				},
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local mason_registry = require("mason-registry")

			mason_registry:on("package:install:success", function()
				vim.defer_fn(function()
					-- trigger FileType event to possibly load this newly installed LSP server
					vim.api.nvim_exec_autocmds("FileType", {
						buffer = vim.api.nvim_get_current_buf(),
						modeline = false,
					})
				end, 100)
			end)

			local function ensure_installed()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mason_registry.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end

			if mason_registry.refresh then
				mason_registry.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},
}
