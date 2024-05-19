local helpers = require("helpers")

local M = {}
M.map = helpers.key.set_map

-- Mode           | Norm | Ins | Cmd | Vis | Sel | Opr | Term | Lang |
-- Command        +------+-----+-----+-----+-----+-----+------+------+
-- [nore]map      | yes  |  -  |  -  | yes | yes | yes |  -   |  -   |
-- n[nore]map     | yes  |  -  |  -  |  -  |  -  |  -  |  -   |  -   |
-- [nore]map!     |  -   | yes | yes |  -  |  -  |  -  |  -   |  -   |
-- i[nore]map     |  -   | yes |  -  |  -  |  -  |  -  |  -   |  -   |
-- c[nore]map     |  -   |  -  | yes |  -  |  -  |  -  |  -   |  -   |
-- v[nore]map     |  -   |  -  |  -  | yes | yes |  -  |  -   |  -   |
-- x[nore]map     |  -   |  -  |  -  | yes |  -  |  -  |  -   |  -   |
-- s[nore]map     |  -   |  -  |  -  |  -  | yes |  -  |  -   |  -   |
-- o[nore]map     |  -   |  -  |  -  |  -  |  -  | yes |  -   |  -   |
-- t[nore]map     |  -   |  -  |  -  |  -  |  -  |  -  | yes  |  -   |
-- l[nore]map     |  -   | yes | yes |  -  |  -  |  -  |  -   | yes  |

-- opts -> "<buffer>", "<nowait>", "<silent>", "<script>", "<expr>" and "<unique>"

_G.custom_keymaps = M

-- set space as leader key
helpers.key.set_leader(" ")

M.setup = function()
	local map = M.map
	-- set my custom keymappings
	map({ "n", "x" }, M.accelerated.down, "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "[Move] Down" })
	map({ "n", "x" }, M.accelerated.up, "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "[Move] Up" })
	map({ "n", "x" }, "n", "h", { desc = "[Move] Left" })
	map({ "n", "x" }, "i", "l", { desc = "[Move] Right" })
	map({ "n", "x" }, M.accelerated.quick_up, "5k", { desc = "[Move] Up Quickly" })
	map({ "n", "x" }, M.accelerated.quick_down, "5j", { desc = "[Move] Down Quickly" })
	map({ "n", "x" }, "N", "0", { desc = "[Move] To Head Of Line" })
	map({ "n", "x" }, "I", "$", { desc = "[Move] To Tail Of Line" })
	map({ "n", "x" }, "W", "5w", { desc = "[Move] To Next Word" })
	map({ "n", "x" }, "B", "5b", { desc = "[Move] To Previous Word" })
	map({ "n", "x" }, "h", "e", { desc = "[Move] To Next Word Tail" })
	map({ "n", "x" }, "<C-M-u>", "5<C-y>", { desc = "[Scroll] Up" })
	map({ "n", "x" }, "<C-M-e>", "5<C-e>", { desc = "[Scroll] Down" })
	map("", "s", "<NOP>", { silent = true })

	map("n", "S", "<CMD>w<CR>", { desc = "Save Current File" })
	map("n", "Q", "<CMD>q<CR>", { desc = "Quit Current Buffer" })
	map("n", "l", "u", { desc = "Undo" })

	map({ "n", "x", "o" }, "k", "i", { desc = "Insert" })
	map({ "n", "x", "o" }, "K", "I", { desc = "Insert At Begin" })

	map("n", "<LEADER><CR>", "<CMD>nohlsearch<CR>", { desc = "No Highlight Search" })
	map("n", "zc", "za", { desc = "Fold Code" })

	map("n", "<", "<<", { desc = "Indent Left" })
	map("n", ">", ">>", { desc = "Indent Right" })
	map("x", "<", "<gv", { desc = "Indent Left" })
	map("x", ">", ">gv", { desc = "Indent Right" })

	map("o", "i", "<NOP>")

	-- Add undo break-points
	map("i", ",", ",<C-g>u")
	map("i", ".", ".<C-g>u")
	map("i", ";", ";<C-g>u")

	map("n", ";su", ":set nosplitbelow<CR>:split<CR>:set splitbelow<CR>", { desc = "[Split] Up" })
	map("n", ";se", ":set splitbelow<CR>:split<CR>", { desc = "[Split] Down" })
	map("n", ";sn", ":set nosplitright<CR>:vsplit<CR>:set splitright<CR>", { desc = "[Split] Left" })
	map("n", ";si", ":set splitright<CR>:vsplit<CR>", { desc = "[Split] Right" })
	map("n", ";<LEADER>u", "<C-w>k", { desc = "Switch To Up Window" })
	map("n", ";<LEADER>e", "<C-w>j", { desc = "Switch To Below Window" })
	map("n", ";<LEADER>n", "<C-w>h", { desc = "Switch To Left Window" })
	map("n", ";<LEADER>i", "<C-w>l", { desc = "Switch To Right Window" })
	map("n", ";<LEADER>w", "<C-w>w", { desc = "Switch To Next Window" })

	map("n", "<M-e>", "<CMD>m .+1<CR>==", { desc = "Move Down" })
	map("n", "<M-u>", "<CMD>m .-2<CR>==", { desc = "Move Up" })
	map("x", "<M-e>", ":m '>+1<CR>gv=gv", { desc = "Move Down" })
	map("x", "<M-u>", ":m '<-2<CR>gv=gv", { desc = "Move Up" })

	map("n", ".", "n", { desc = "Search Next" })
	map("n", ",", "N", { desc = "Search Previous" })

	local pattern = "CustomKeymaps"
	vim.api.nvim_exec_autocmds("User", {
		pattern = pattern,
		modeline = false,
	})
end

M.treesitter_incremental_selection_keymaps = {
	init_selection = "<S-Space>",
	node_incremental = "<S-Space>",
	scope_incremental = "<S-M-Space>",
	node_decremental = "<S-BS>",
}

M.accelerated = {
	down = "e",
	up = "u",
	quick_down = "E",
	quick_up = "U",
}

M.boole = {
	increment = "<C-a>",
	decrement = "<C-x>",
}

M.todo_comments = {
	next = "]t",
	previous = "[t",
}

M.format = ";ff"

M.lsp = {
	goto_definitions = "gd",
	goto_references = "gr",
	goto_declaration = "gD",
	goto_implementations = "gi",
	goto_type_definitions = "gy",
	hover = "H",
	normal_signature_help = "gh",
	insert_signature_help = "<C-h>",
	code_action = "<LEADER>ca",
	source_action = "<LEADER>cA",
	codelens = "<LEADER>cc",
	codelens_refresh = "<LEADER>cC",
	rename = "<LEADER>rn",
}

M.cmp = {
	select_next = "<C-e>",
	select_prev = "<C-u>",
	scroll_down = "<M-e>",
	scroll_up = "<M-u>",
	complete = "<C-i>",
	confirm = "<CR>",
	abort = "<C-n>",
	confirm_replace = "<S-CR>",
	newline = "<C-CR>",
	snippet_next = "<TAB>",
	snippet_prev = "<S-TAB>",
}

return M
