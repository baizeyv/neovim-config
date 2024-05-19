local M = {}

M.setup = function()
	vim.o.guifont = "RecMonoLinear Nerd Font Mono:h11"
	if vim.g.neovide then
		vim.g.neovide_transparency = 0.85
		vim.g.neovide_hide_mouse_when_typing = true
		vim.g.neovide_fullscreen = true
		vim.g.neovide_remember_window_size = true
		vim.g.neovide_profiler = false
		vim.g.neovide_cursor_vfx_mode = "wireframe"
	end

	vim.opt.foldmethod = "expr"
	vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

	vim.opt.linespace = 1
	if not vim.env.SSH_TTY then
		vim.opt.clipboard = "unnamedplus" -- sync with system clipboard
	end

	vim.opt.autowrite = true -- enable auto write
	vim.opt.completeopt = "menu,menuone,noselect"
	vim.opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
	vim.opt.confirm = true -- Confirm to save changes before exiting modified buffer
	vim.opt.cursorline = true -- Enable highlighting of the current line
	vim.opt.expandtab = true -- Use spaces instead of tabs
	vim.opt.formatoptions = "jcroqlnt" -- tcqj
	vim.opt.grepformat = "%f:%l:%c:%m"
	vim.opt.grepprg = "rg --vimgrep"
	vim.opt.ignorecase = true -- Ignore case
	vim.opt.inccommand = "nosplit" -- preview incremental substitute
	vim.opt.laststatus = 3 -- global statusline
	vim.opt.list = true -- Show some invisible characters (tabs...
	vim.opt.mouse = "a" -- Enable mouse mode
	vim.opt.number = true -- Print line number
	vim.opt.pumblend = 10 -- Popup blend
	vim.opt.pumheight = 10 -- Maximum number of entries in a popup
	vim.opt.relativenumber = true -- Relative line numbers
	vim.opt.scrolloff = 4 -- Lines of context
	vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
	vim.opt.shiftround = true -- Round indent
	vim.opt.shiftwidth = 4 -- Size of an indent
	vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
	vim.opt.showmode = false -- Dont show mode since we have a statusline
	vim.opt.sidescrolloff = 8 -- Columns of context
	vim.opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
	vim.opt.smartcase = true -- Don't ignore case with capitals
	vim.opt.smartindent = true -- Insert indents automatically
	vim.opt.spelllang = { "en" }
	vim.opt.splitbelow = true -- Put new windows below current
	vim.opt.splitkeep = "screen"
	vim.opt.splitright = true -- Put new windows right of current
	vim.opt.tabstop = 4 -- Number of spaces tabs count for
	vim.opt.termguicolors = true -- True color support
	if not vim.g.vscode then
		vim.opt.timeoutlen = 300 -- Lower than default (1000) to quickly trigger which-key
	end
	vim.opt.undofile = true
	vim.opt.undolevels = 10000
	vim.opt.updatetime = 1000 -- Save swap file and trigger CursorHold
	vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
	vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
	vim.opt.winminwidth = 5 -- Minimum window width
	vim.opt.wrap = false -- Disable line wrap
	vim.opt.fillchars = {
		foldopen = "",
		foldclose = "",
		fold = " ",
		foldsep = " ",
		diff = "╱",
		eob = " ",
	}

	if vim.fn.has("nvim-0.10") == 1 then
		vim.opt.smoothscroll = true
	end

	-- Folding
	vim.opt.foldlevel = 99
end

return M
