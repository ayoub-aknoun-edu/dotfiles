-- JS/TS linting is handled by the eslint LSP server (see lsp.lua),
-- so eslint_d is not configured here to avoid duplicate diagnostics.
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "ruff" },
        sh = { "shellcheck" },
      },
      linters = {
        -- only run ruff when it is installed (avoids ENOENT errors)
        ruff = {
          condition = function()
            return vim.fn.executable("ruff") == 1
          end,
        },
      },
    },
  },
}
