-- Wallpaper-driven colors: ~/.config/theme/generated/nvim.lua is a base16
-- palette written by matugen (theme/matugen, via ~/.local/bin/rice-wall),
-- which sends SIGUSR1 to running nvims after a wallpaper change.
-- No palette yet → LazyVim's default tokyonight.

local PALETTE = vim.fn.expand("~/.config/theme/generated/nvim.lua")

local function palette()
  local ok, colors = pcall(dofile, PALETTE)
  return ok and type(colors) == "table" and colors or nil
end

local function apply()
  local colors = palette()
  if colors then
    require("base16-colorscheme").setup(colors)
  else
    require("tokyonight").load()
  end
end

return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        apply()
        local signal = vim.uv.new_signal()
        if signal then
          signal:start("sigusr1", vim.schedule_wrap(apply))
        end
      end,
    },
  },
}
