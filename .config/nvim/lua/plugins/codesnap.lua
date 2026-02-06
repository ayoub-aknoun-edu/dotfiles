return {
  "mistricky/codesnap.nvim",
  build = "make",
  cmd = {
    "CodeSnap",
    "CodeSnapSave",
    "CodeSnapASCII",
    "CodeSnapHighlight",
    "CodeSnapHighlightSave",
  },
  config = function()
    require("codesnap").setup({
      watermark = "",
    })
    -- Remove the absolute generator .so from cpath to avoid hijacking
    -- unrelated C module loads (e.g., blink.cmp fuzzy).
    local ok_fetch, fetch = pcall(require, "codesnap.fetch")
    if ok_fetch then
      local ok_lib, lib_path = pcall(fetch.ensure_lib)
      if ok_lib and lib_path then
        local escaped = lib_path:gsub("([%%%^%$%(%)%%.%[%]%*%+%-%?])", "%%%1")
        package.cpath = package.cpath:gsub(";" .. escaped, "")
      end
    end
  end,
}
