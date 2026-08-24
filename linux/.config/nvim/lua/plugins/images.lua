-- lua/plugins/images.lua
-- Inline images for leetcode.nvim, drawn with the kitty graphics protocol --
-- hence the KITTY_WINDOW_ID gate; elsewhere it stays dormant and images fall
-- back to links. Needs kitty + imagemagick (the CLI, not the luarock).

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
