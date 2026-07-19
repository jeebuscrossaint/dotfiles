-- lua/plugins/images.lua
-- ============================================================================
-- image.nvim = render real images inside Neovim (used by leetcode.nvim to show
-- problem diagrams inline). It draws via the KITTY GRAPHICS PROTOCOL, so it only
-- works when Neovim is running inside kitty — NOT in Neovide or foot.
--
-- Because of that, this plugin is gated with `cond`: it only loads when the
-- KITTY_WINDOW_ID environment variable is present (i.e. you launched nvim from
-- kitty). Everywhere else it stays dormant and images fall back to plain links.
--
-- Requirements (install once):  kitty + imagemagick
--   sudo pacman -S kitty imagemagick
-- No luarocks needed — we use ImageMagick's CLI via the `magick_cli` processor.
-- ============================================================================

return {
  "3rd/image.nvim",
  cond = function() return vim.env.KITTY_WINDOW_ID ~= nil end,
  lazy = true, -- loaded on demand by leetcode.nvim (its dependent), not at startup
  opts = {
    backend = "kitty",
    processor = "magick_cli", -- use the ImageMagick CLI (no `magick` luarock required)
    -- leetcode.nvim drives rendering itself, so leave the generic file/markdown
    -- integrations off to avoid surprise image draws in normal buffers.
    integrations = {
      markdown = { enabled = false },
      neorg = { enabled = false },
      html = { enabled = false },
      css = { enabled = false },
    },
    window_overlap_clear_enabled = true, -- hide images when a window covers them
    editor_only_render_when_focused = true,
  },
}
