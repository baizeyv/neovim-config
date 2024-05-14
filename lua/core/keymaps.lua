local helpers = require("helpers")
local map = helpers.key.set_map

-- Mode  | Norm | Ins | Cmd | Vis | Sel | Opr | Term | Lang |
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

local M = {}

_G.custom_keymaps = M

-- set space as leader key
helpers.key.set_leader(" ")

M.setup = function()
    -- set my custom keymappings
    map({ "n", "x" }, "e", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "[Move] Down" })
    map({ "n", "x" }, "u", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "[Move] Up" })
    map({ "n", "x" }, "n", "h", { desc = "[Move] Left" })
    map({ "n", "x" }, "i", "l", { desc = "[Move] Right" })
    map({ "n", "x" }, "U", "5k", { desc = "[Move] Up Quickly" })
    map({ "n", "x" }, "E", "5j", { desc = "[Move] Down Quickly" })
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

    map("n", "su", ":set nosplitbelow<CR>:split<CR>:set splitbelow<CR>", { desc = "[Split] Up" })
    map("n", "se", ":set splitbelow<CR>:split<CR>", { desc = "[Split] Down" })
    map("n", "sn", ":set nosplitright<CR>:vsplit<CR>:set splitright<CR>", { desc = "[Split] Left" })
    map("n", "si", ":set splitright<CR>:vsplit<CR>", { desc = "[Split] Right" })
    map("n", "<LEADER>u", "<C-w>k", { desc = "Switch To Up Window" })
    map("n", "<LEADER>e", "<C-w>j", { desc = "Switch To Below Window" })
    map("n", "<LEADER>n", "<C-w>h", { desc = "Switch To Left Window" })
    map("n", "<LEADER>i", "<C-w>l", { desc = "Switch To Right Window" })
    map("n", "<LEADER>w", "<C-w>w", { desc = "Switch To Next Window" })

    map("n", "<M-e>", "<CMD>m .+1<CR>==", { desc = "Move Down" })
    map("n", "<M-u>", "<CMD>m .-2<CR>==", { desc = "Move Up" })
    map("x", "<M-e>", ":m '>+1<CR>gv=gv", { desc = "Move Down" })
    map("x", "<M-u>", ":m '<-2<CR>gv=gv", { desc = "Move Up" })
end

M.treesitter_incremental_selection_keymaps = {
    init_selection = "<C-Space>",
    node_incremental = "<C-Space>",
    scope_incremental = "<C-1>",
    node_decremental = "<BS>"
}

return M
