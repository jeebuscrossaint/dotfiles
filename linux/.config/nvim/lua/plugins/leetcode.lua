-- lua/plugins/leetcode.lua
-- ============================================================================
-- leetcode.nvim = grind LeetCode without leaving Neovim. Browse problems, read
-- the description in a side panel, write your solution with full LSP + your
-- keymaps, and submit — all in the editor.
--
--   :Leet            open the LeetCode dashboard
--   :Leet run        run your solution against the sample tests
--   :Leet submit     submit it
--   :Leet lang       switch the solution language
--   :Leet menu       command menu (browse everything)
--   <leader>lc       shortcut for :Leet
--
-- FIRST TIME: you need to sign in so it can talk to your account. Run
--   :Leet menu   -> Sign In   (it walks you through pasting your session cookie)
-- Free problems are browsable; running/submitting needs the sign-in.
-- ============================================================================

return {
  "kawre/leetcode.nvim",
  build = ":TSUpdate html", -- questions render as HTML → needs the html parser
  cmd = "Leet",
  keys = {
    { "<leader>lc", "<cmd>Leet<CR>", desc = "Open LeetCode" },
  },
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    -- Default language for new solutions. You're doing C++/Python — pick one;
    -- switch anytime with :Leet lang.  Valid: "cpp", "python3", "c", "rust", ...
    lang = "cpp",
    -- Where solution files are stored (created if missing).
    storage = { home = vim.fn.stdpath("data") .. "/leetcode" },
    -- No terminal image support needed; keeps it dependency-light.
    image_support = false,
  },
}
