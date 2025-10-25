return {
  {
    "akinsho/flutter-tools.nvim",
    ft = { "dart" },
    dependencies = { "nvim-lua/plenary.nvim", "stevearc/dressing.nvim" },
    opts = {
      lsp = {
        color = { enabled = true },
      },
      widget_guides = { enabled = true },
      closing_tags = { highlight = "Comment", prefix = ">> " },
    },
  },
}
