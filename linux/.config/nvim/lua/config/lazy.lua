-- lua/config/lazy.lua
-- ============================================================================
-- Bootstraps lazy.nvim (the plugin manager) and then loads every plugin.
--
-- lazy.nvim: https://github.com/folke/lazy.nvim
--   - It auto-installs itself the first time (the block below).
--   - `{ import = "plugins" }` tells it to load EVERY file in lua/plugins/,
--     so to add a plugin you just drop a new file in there — no editing here.
--
-- Useful commands once you're in Neovim:
--   :Lazy         open the plugin manager UI (install/update/profile/etc.)
--   :Lazy sync    install missing + update + clean removed plugins
--   :Lazy update  update plugins
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Clone lazy.nvim if it isn't installed yet
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

-- Add lazy.nvim to the runtime path so `require("lazy")` works
vim.opt.rtp:prepend(lazypath)

-- Load all plugins from lua/plugins/
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  -- Check for plugin updates in the background, but don't nag about it
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  ui = { border = "rounded" },
})
