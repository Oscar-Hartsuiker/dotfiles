local ok, base46 = pcall(require, "base46")
if ok and base46.theme_tables["noctalia-b46"] then
  return require("lualine.themes._base46")("noctalia-b46")
end
local base = vim.o.background == "light" and "catppuccin-latte" or "catppuccin"
return require("lualine.themes._base46")(base)
