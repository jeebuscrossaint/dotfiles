-- lua/plugins/gitsigns.lua
-- ============================================================================
-- gitsigns.nvim = git info right in the editor: which lines are added/changed/
-- removed (shown in the left gutter), plus staging and blame from inside nvim.
--
-- Keymaps:
--   ]c / [c            next / previous changed hunk
--   <leader>hs         stage hunk        <leader>hr  reset (undo) hunk
--   <leader>hp         preview hunk      <leader>hb  blame this line
--   <leader>hd         diff this file
-- ============================================================================

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
    },
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = "Git: " .. desc })
      end
      map("n", "]c", function() gs.nav_hunk("next") end, "Next hunk")
      map("n", "[c", function() gs.nav_hunk("prev") end, "Previous hunk")
      map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
      map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
      map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("n", "<leader>hd", gs.diffthis, "Diff this file")
    end,
  },
}
