-- lua/plugins/debug.lua
-- ============================================================================
-- Debugging with nvim-dap (Debug Adapter Protocol) + a graphical UI.
-- Set breakpoints, run your program, step line-by-line, and inspect variables
-- — the same idea as VS Code's debugger, inside Neovim.
--
-- Adapters used (installed via Mason):
--   codelldb  -> C / C++ / CUDA (host code)
--   debugpy   -> Python
--
-- Keymaps:
--   <F5>          start / continue        <S-F5>       stop / terminate
--   <F10>         step over               <F11>        step into      <F12> step out
--   <leader>db    toggle breakpoint       <leader>dB   conditional breakpoint
--   <leader>du    toggle the debugger UI  <leader>dr   open REPL
--   <leader>de    evaluate expression under cursor / selection
--
-- The UI (variables, call stack, breakpoints, watches, console) opens
-- automatically when a session starts and closes when it ends.
--
-- NOTE ON CUDA: codelldb debugs the *host* (CPU) side of a CUDA program. To
-- step inside GPU kernels you need `cuda-gdb` — a heavier, separate setup we
-- can add later if you get into kernel-level debugging.
-- ============================================================================

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- Graphical UI panels for dap
    { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    -- Show variable values inline as virtual text next to your code
    { "theHamsta/nvim-dap-virtual-text", opts = {} },
    -- Zero-config Python debugging via debugpy
    "mfussenegger/nvim-dap-python",
    -- Lets Mason install the debug adapters (codelldb, debugpy)
    { "jay-babu/mason-nvim-dap.nvim", dependencies = { "mason-org/mason.nvim" } },
  },
  keys = {
    { "<F5>", function() require("dap").continue() end, desc = "Debug: start / continue" },
    { "<S-F5>", function() require("dap").terminate() end, desc = "Debug: terminate" },
    { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
    { "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Open debug REPL" },
    { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
    { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Evaluate expression" },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- Ask Mason to install the adapters if they're missing.
    require("mason-nvim-dap").setup({
      ensure_installed = { "codelldb", "python" }, -- "python" = debugpy
      automatic_installation = true,
      handlers = {}, -- use our own configs below, not the auto-generated ones
    })

    -- ── C / C++ / CUDA via codelldb ──────────────────────────────────────────
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
        args = { "--port", "${port}" },
      },
    }
    local c_config = {
      {
        name = "Launch executable",
        type = "codelldb",
        request = "launch",
        -- Prompt for the compiled binary to debug (build it first, e.g. with -g).
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }
    dap.configurations.c = c_config
    dap.configurations.cpp = c_config
    dap.configurations.cuda = c_config -- host-side debugging of .cu programs

    -- ── Python via debugpy ───────────────────────────────────────────────────
    -- Point dap-python at Mason's debugpy virtualenv.
    require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")

    -- ── Nicer breakpoint signs ───────────────────────────────────────────────
    vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticInfo", linehl = "Visual", numhl = "" })

    -- ── UI: open on session start, close on end ──────────────────────────────
    dapui.setup()
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
  end,
}
