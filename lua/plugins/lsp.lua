local helper = require("helpers")

return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "folke/neoconf.nvim",
            "folke/neodev.nvim",
            "mason.nvim",
            "williamboman/mason-lspconfig.nvim"
        },
        opts = {
            -- enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
            -- be aware that you also will need to properly configure your LSP server to provide the inlay hints.
            inlay_hints = {
                enable = true
            },
            -- enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
            -- be aware that you also will need to properly configure your LSP server to provide the code lenses.
            codelens = {
                enable = true
            }
        },
        config = function(_, opts)
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
                helper.lsp.on_attach(function (client, buffer)
                    if client.supports_method("textDocument/codeLens") then
                        vim.lsp.codelens.refresh()
                        -- autocmd BufEnter, CursorHold, InsertLeave <buffer> lua vim.lsp.codelens.refresh()
                        vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                            buffer = buffer,
                            callback = vim.lsp.codelens.refresh
                        })
                    end
                end)
            end
        end
    },
    {
        "williamboman/mason.nvim",
        cmd = {
            "Mason", "MasonUpdate", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog"
        },
        build = ":MasonUpdate",
        opts = {
            ensure_installed = { "stylua", "shfmt" },
            ---@since 1.0.0
            -- The directory in which to install packages.
            -- install_root_dir = require("mason-core.path").concat { vim.fn.stdpath "data", "mason" },
            install_root_dir = vim.fn.stdpath "data" .. "/mason",

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

            mason_registry:on("package:install:success", function ()
                vim.defer_fn(function ()
                    -- trigger FileType event to possibly load this newly installed LSP server
                    vim.api.nvim_exec_autocmds("FileType", {
                        buffer = vim.api.nvim_get_current_buf(),
                        modeline = false
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
        end
    },
}
