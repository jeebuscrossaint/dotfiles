-- lua/plugins/animations.lua
-- ============================================================================
-- Neovide-style motion for TERMINAL Neovim (kitty): a smooth cursor smear and
-- animated scrolling. These are gated with `cond = not vim.g.neovide` because
-- Neovide already renders its own (nicer, GPU-drawn) animations — running these
-- on top would fight with it.
--
-- Note: terminals can't do shadows or real blur (those need a pixel renderer
-- like Neovide's), so this covers cursor + scroll + resize motion only.
--
-- Tune or disable: edit the opts below, or delete this file to turn it all off.
-- ============================================================================

return {
  -- ── Cursor smear (the Neovide-signature trailing cursor) ───────────────────
  {
    "sphamba/smear-cursor.nvim",
    cond = function() return not vim.g.neovide end,
    event = "VeryLazy",
    opts = {
      -- Higher = snappier, lower = longer trail. These feel close to Neovide.
      stiffness = 0.8,
      trailing_stiffness = 0.5,
      trailing_exponent = 0.1,
      distance_stop_animating = 0.5,
      -- Smear when jumping far (search, G, gg) as well as normal moves.
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
    },
  },

  -- ── Smooth scrolling + animated window resize ──────────────────────────────
  {
    "echasnovski/mini.animate",
    cond = function() return not vim.g.neovide end,
    event = "VeryLazy",
    config = function()
      local animate = require("mini.animate")
      animate.setup({
        cursor = { enable = false }, -- smear-cursor.nvim owns the cursor
        scroll = { enable = true },  -- animate <C-d>/<C-u>, gg, G, etc.
        resize = { enable = true },  -- animate window resizes
        open = { enable = false },   -- off: keeps floats (telescope/noice) instant
        close = { enable = false },
      })
    end,
  },
}
