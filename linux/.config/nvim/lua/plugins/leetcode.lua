-- lua/plugins/leetcode.lua
-- leetcode.nvim — browse, solve and submit without leaving Neovim.
--
--   :Leet            open the LeetCode dashboard
--   :Leet run        run your solution against the sample tests
--   :Leet submit     submit it
--   :Leet lang       switch the solution language
--   :Leet menu       command menu (browse everything)
--   <leader>lc       shortcut for :Leet
--
-- FIRST TIME: :Leet menu -> Sign In. Browsing works without it; running and
-- submitting do not.

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
    "3rd/image.nvim", -- inline problem images (only active in kitty; see images.lua)
  },
  opts = {
    -- Default language for new solutions. You're doing C++/Python — pick one;
    -- switch anytime with :Leet lang.  Valid: "cpp", "python3", "c", "rust", ...
    lang = "cpp",
    -- Where solution files are stored (created if missing).
    storage = { home = vim.fn.stdpath("data") .. "/leetcode" },
    -- Render problem diagrams inline — but only when running inside kitty, which
    -- is the only terminal here that supports the graphics protocol. In Neovide
    -- or foot this is false and images stay as (openable) links.
    image_support = vim.env.KITTY_WINDOW_ID ~= nil,
  },
}
