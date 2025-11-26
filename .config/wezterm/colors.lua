local M = {}

local wezterm = require("wezterm")

local custom_mocha = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom_mocha.background = "#1e1e1e"

M.custom_mocha = custom_mocha

return M
