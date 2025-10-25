return {
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = function(bufnr)
        -- disable if large file
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > 256 * 1024 then return nil end
        return { timeout_ms = 2000, lsp_fallback = true }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "ruff_organize_imports" }, -- or { "black", "isort" }
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        yaml = { "yamlfmt" },
        sh = { "shfmt" },
        go = { "gofumpt", "golines" },
        cpp = { "clang-format" },
        c = { "clang-format" },
        dart = { "dart_format" },
      },
      formatters = {
        yamlfmt = { command = "yamlfmt", args = { "-formatter", "basic", "-indentless_arrays=true" } },
      },
    },
  },
}
