-- lua/config/options.lua
-- ============================================================================
-- Editor behaviour. `vim.opt.X = Y` is how you set a setting.
-- Every line has a comment so you know what it does and can change it.
-- ============================================================================

local opt = vim.opt

-- Line numbers -------------------------------------------------------------
opt.number = true          -- show the absolute line number of the current line
opt.relativenumber = true  -- other lines show distance from cursor (great for 5j / 3k motions)

-- Indentation --------------------------------------------------------------
opt.tabstop = 4            -- a <Tab> looks 4 spaces wide
opt.shiftwidth = 4         -- one indent level = 4 spaces
opt.expandtab = true       -- pressing <Tab> inserts spaces, not a real tab
opt.smartindent = true     -- auto-indent new lines sensibly
opt.autoindent = true      -- keep the previous line's indent on a new line

-- Search -------------------------------------------------------------------
opt.ignorecase = true      -- searching is case-insensitive...
opt.smartcase = true       -- ...unless you type an uppercase letter
opt.hlsearch = true        -- highlight all matches (clear them with <Esc> — see keymaps)
opt.incsearch = true       -- jump to matches as you type

-- UI -----------------------------------------------------------------------
opt.termguicolors = true   -- enable 24-bit colours (needed for modern themes)
opt.signcolumn = "yes"     -- always show the left gutter (git/LSP signs) so text doesn't jump
opt.cursorline = true      -- subtly highlight the line the cursor is on
opt.wrap = false           -- don't wrap long lines (they scroll horizontally instead)
opt.scrolloff = 8          -- keep 8 lines visible above/below the cursor
opt.sidescrolloff = 8      -- same, but horizontally
opt.showmode = false       -- the statusline already shows the mode, so hide the built-in one
opt.splitright = true      -- vertical splits open on the right
opt.splitbelow = true      -- horizontal splits open below

-- Files & undo -------------------------------------------------------------
opt.undofile = true        -- persist undo history to disk (undo even after closing a file!)
opt.swapfile = false       -- no annoying .swp files
opt.backup = false         -- no backup files

-- Editing niceties ---------------------------------------------------------
opt.mouse = "a"            -- enable the mouse in all modes (handy while learning)
opt.clipboard = "unnamedplus" -- yank/paste uses the system clipboard by default
opt.updatetime = 250       -- faster response for things like git signs (default is 4000ms)
opt.timeoutlen = 400       -- how long to wait for a multi-key shortcut (which-key uses this)

-- Enable a fast Treesitter-based folding without folding everything on open
opt.foldlevelstart = 99    -- start with all folds open

-- GUI font ------------------------------------------------------------------
-- `guifont` (used by GUI clients like Neovide; terminal Neovim ignores it) is
-- set by COAT — see the generated ~/.local/share/nvim/site/colors/coat.lua,
-- which pulls the family + size from coat.yaml so it stays in sync system-wide.
-- To change it, edit `font.monospace` / `sizes.terminal` in coat.yaml and run
-- `coat apply neovim`. (Don't set opt.guifont here — coat would override it.)

-- Neovide-only tweaks (these `vim.g.neovide_*` settings do nothing outside Neovide).
if vim.g.neovide then
  vim.g.neovide_padding_top = 8
  vim.g.neovide_padding_bottom = 8
  vim.g.neovide_padding_left = 8
  vim.g.neovide_padding_right = 8
  vim.g.neovide_cursor_animation_length = 0.05 -- subtle cursor trail; set 0 to disable
  -- vim.g.neovide_scale_factor = 1.0           -- zoom the whole UI if you want
end
