-- lua/config/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- 1) Core LazyVim (must be first)
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- 2) LazyVim EXTRAS (must come before your own plugins)
    -- TypeScript/Angular/React ecosystem
    { import = "lazyvim.plugins.extras.lang.typescript" },
    -- JSON (schemastore, jsonls, treesitter tweaks)
    { import = "lazyvim.plugins.extras.lang.json" },
    -- Java / Spring (jdtls integration)
    { import = "lazyvim.plugins.extras.lang.java" },
    -- Optional: ESLint wiring (if you use eslint/eslint_d)
    -- { import = "lazyvim.plugins.extras.linting.eslint" },

    -- 3) Your own plugins (after all extras)
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
