-- Formatting via conform.nvim.
-- LazyVim formats on save by default (toggle with <leader>uf / <leader>uF),
-- so don't set `format_on_save` here.
return {
  {
    "stevearc/conform.nvim",
    opts = {
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
        yaml = { "yamlfmt" }, -- K8s-friendly formatter
        sh = { "shfmt" },
        go = { "gofumpt", "golines" },
        cpp = { "clang-format" },
        c = { "clang-format" },
        dart = { "dart_format" },
      },
      formatters = {
        yamlfmt = {
          command = "yamlfmt",
          args = { "-formatter", "basic", "-indentless_arrays=true" },
        },
      },
    },
  },
}
