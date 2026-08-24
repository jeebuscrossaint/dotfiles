-- lua/plugins/animations.lua
-- Cursor smear + animated scrolling for TERMINAL Neovim. Gated on
-- `not vim.g.neovide`: Neovide draws its own and the two would fight.

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
