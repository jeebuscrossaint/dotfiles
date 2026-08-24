-- lua/plugins/colorscheme.lua
-- No theme plugin: coat writes a real colorscheme to
-- ~/.local/share/nvim/site/colors/coat.lua, which is on the runtimepath already.
-- This spec exists only to apply it at startup, with a fallback for a fresh
-- machine where `coat apply neovim` has not run yet.

return {
  -- dir + name keep lazy.nvim happy without cloning anything.
  "coat-theme",
  dir = vim.fn.stdpath("data") .. "/site", -- points at where coat writes colors/coat.lua
  name = "coat-theme",
  lazy = false,
  priority = 1000, -- load before everything else so nothing flashes unstyled
  config = function()
    local ok = pcall(vim.cmd.colorscheme, "coat")
    if not ok then
      vim.notify(
        "coat colorscheme not found — run `coat apply neovim` to generate it. Using default for now.",
        vim.log.levels.WARN
      )
      pcall(vim.cmd.colorscheme, "default")
    end
  end,
}
