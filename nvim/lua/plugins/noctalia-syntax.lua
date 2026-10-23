local function palette(field)
  local ok, lines = pcall(vim.fn.readfile, vim.fn.stdpath("config") .. "/colors/noctalia.lua")
  if not ok then
    return nil
  end
  return table.concat(lines, "\n"):match("\n%s*" .. field .. "%s*=%s*'(#%x%x%x%x%x%x)'")
end

local function apply_syntax()
  if vim.g.colors_name ~= "noctalia" then
    return
  end
  local ok, base46 = pcall(require, "base46")
  if not ok or not base46._DMS_SUPPORT then
    return
  end
  local primary = palette("primary")
  local surface = palette("surface")
  if not primary or not surface then
    return
  end
  local base = vim.o.background == "light" and "catppuccin-latte" or "catppuccin"
  local builtin = base46.get_builtin_theme(base)
  if not builtin then
    return
  end
  local theme = vim.deepcopy(builtin)
  theme = base46.theme_harmonize(theme, primary, 0.5)
  theme = base46.theme_set_bg(theme, surface)
  base46.theme_tables["noctalia-b46"] = theme
  base46.load("noctalia-b46")
  vim.g.colors_name = "noctalia"
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "noctalia",
  callback = apply_syntax,
})

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(apply_syntax)
  end,
})

return {}
