-- ~/.config/nvim/init.lua
--   lua/config/options.lua   editor settings
--   lua/config/keymaps.lua   editor-wide shortcuts
--   lua/config/lazy.lua      plugin manager
--   lua/plugins/*.lua        one file per plugin, imported automatically
--
-- The leader MUST be set before plugins load, hence right here at the top.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.lazy")
