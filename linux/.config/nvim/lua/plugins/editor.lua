-- lua/plugins/editor.lua
-- ============================================================================
-- Small quality-of-life editing plugins that don't need much explanation.
-- ============================================================================

return {
  -- Auto-close brackets/quotes: type ( and get (), etc.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Highlight and list TODO / FIXME / HACK / NOTE comments.
  --   <leader>ft   search all TODOs with Telescope
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Find TODOs" },
    },
  },

  -- "gc" to comment: gcc toggles a line, gc in visual mode toggles a selection.
  -- (Neovim has built-in commenting, but this adds smart per-language handling.)
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Show a vertical guide line for each indent level.
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
    },
  },

  -- Add/change/delete surrounding pairs: e.g. ysiw" wraps a word in quotes,
  -- cs"' changes "double" to 'single', ds( removes surrounding parens.
  {
    "kylechui/nvim-surround",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}
