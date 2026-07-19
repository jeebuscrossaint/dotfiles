-- ~/.config/nvim/init.lua
-- ============================================================================
-- This is the FIRST file Neovim reads. It just wires everything together.
-- The actual config is split into small files under lua/ so nothing is a mess:
--
--   lua/config/options.lua   -> editor settings (line numbers, tabs, etc.)
--   lua/config/keymaps.lua   -> your custom keyboard shortcuts
--   lua/config/lazy.lua      -> installs the plugin manager + loads plugins
--   lua/plugins/*.lua        -> one file per plugin (added automatically)
--
-- Leader key = the "prefix" for most custom shortcuts. We use Space.
-- It MUST be set before plugins load, so it lives right here at the top.
-- ============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.lazy")
