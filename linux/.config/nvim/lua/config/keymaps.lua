-- lua/config/keymaps.lua
-- ============================================================================
-- Your custom keyboard shortcuts.
--
-- The pattern is:  vim.keymap.set(mode, keys, action, { desc = "..." })
--   mode: "n" = normal, "i" = insert, "v" = visual, "x" = visual block, "t" = terminal
--   desc: a description — which-key shows this in the popup menu, so always add one.
--
-- Plugin-specific shortcuts (Telescope, LSP, file tree...) live in their own
-- plugin files under lua/plugins/. This file is only for editor-wide basics.
-- ============================================================================

local map = vim.keymap.set

-- Clear search highlight with <Esc> in normal mode
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Save & quit (leader = Space)
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write (save) file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })

-- Move between split windows with Ctrl + h/j/k/l (like vim motions)
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize splits with arrow keys
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Open a vertical / horizontal split
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split window horizontally" })

-- Move selected lines up/down in visual mode (J/K) and re-indent
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep the cursor centred when jumping half-pages and through search results
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centred)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centred)" })
map("n", "n", "nzzzv", { desc = "Next search result (centred)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centred)" })

-- In visual mode, stay in visual mode after indenting with < / >
map("v", "<", "<gv", { desc = "Indent left (keep selection)" })
map("v", ">", ">gv", { desc = "Indent right (keep selection)" })

-- Paste over a selection WITHOUT overwriting your clipboard
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking selection" })

-- Buffer navigation (buffers = open files). <Tab> / <S-Tab> to cycle.
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close (delete) buffer" })
