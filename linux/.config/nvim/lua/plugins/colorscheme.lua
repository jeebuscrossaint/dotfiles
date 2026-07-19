-- lua/plugins/colorscheme.lua
-- ============================================================================
-- Theme. You theme your whole system with `coat`, and coat now has a native
-- `neovim` module (see ~/Projects/coat) that writes a real colorscheme to:
--
--   ~/.local/share/nvim/site/colors/coat.lua
--
-- That path is on Neovim's runtimepath automatically, so `:colorscheme coat`
-- just works — and whenever you run `coat apply` with a new scheme, Neovim
-- picks up the new colors too (restart nvim, or run :colorscheme coat).
--
-- We don't need a theme *plugin* at all: coat generates the colorscheme.
-- The tiny spec below just runs at startup and applies it, with a fallback to
-- the built-in "default" theme in case coat hasn't generated the file yet
-- (e.g. on a fresh machine before you've run `coat apply neovim`).
-- ============================================================================

return {
  -- A do-nothing "plugin" whose only job is to run config at startup.
  -- (dir + name + a virtual path keeps lazy.nvim happy without cloning anything.)
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
