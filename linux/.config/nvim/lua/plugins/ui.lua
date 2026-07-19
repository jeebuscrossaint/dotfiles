-- lua/plugins/ui.lua
-- ============================================================================
-- Visual niceties: a statusline, a keymap-hint popup, and prettier icons.
-- ============================================================================

return {
  -- lualine: the statusline at the bottom (mode, file, git branch, diagnostics)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto", -- picks up your coat colors automatically
        section_separators = "",
        component_separators = "|",
        globalstatus = true, -- one statusline for the whole window, not per-split
      },
    },
  },

  -- which-key: after you press <leader> (Space), a popup shows every shortcut
  -- available and what it does. This is your cheat-sheet while learning — just
  -- press Space and wait a moment.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      -- Human-readable names for your leader-key groups (shown in the popup)
      spec = {
        { "<leader>f", group = "Find / Format" },
        { "<leader>h", group = "Git Hunks" },
        { "<leader>s", group = "Splits" },
        { "<leader>b", group = "Buffers" },
        { "<leader>d", group = "Debug" },
        { "<leader>l", group = "LeetCode" },
      },
    },
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Show buffer-local keymaps",
      },
    },
  },

  -- Nerd-font icons used by lualine, telescope, neo-tree, etc.
  -- (Requires a Nerd Font in your terminal — you already use Lilex Nerd Font.)
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
