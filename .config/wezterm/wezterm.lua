local wezterm = require("wezterm")
local colors = require("colors")

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

--
-- Open bash as a non-login shell (auto-tmux for me)
--
config.default_prog = { "/usr/bin/bash" }

config.color_schemes = { ["custom-catpuccin-mocha"] = colors.custom_mocha }
config.color_scheme = "custom-catpuccin-mocha"

config.font_size = 10.0
config.font = wezterm.font_with_fallback({
  {
    family = "Fira Code",
    weight = "Regular",
    harfbuzz_features = {
      -- https://wezterm.org/config/font-shaping.html
      -- https://github.com/tonsky/FiraCode/wiki/How-to-enable-stylistic-sets
      "ss01", -- r
      "ss02", -- <= >=
      "ss03", -- &
      "ss04", -- $
      "ss08", -- == === != !==
      "ss09", -- >>= <<= ||= |=
      "cv30", -- |
    },
  },
  { family = "Ubuntu Mono", scale = 1.2, weight = "Regular" },
  -- $ wezterm ls-font --list-system | less
})

--
-- Emulate Gnome Terminal's font look-and-feel (Freetype vs Pango + Cairo)
--
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"
config.font_rules = {}
config.cell_width = 1.0
config.line_height = 1.05

--
-- Tab behavior (disable fancy tab bar, hides default tab bar unless needed)
--
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
-- enable_tab_bar = false,

-- Use Alt+Space for window menu, Alt+F7 for moving the window
config.window_decorations = "NONE"
-- Make the title bar and the tab bar one and the same (fancy or not)
-- config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.window_padding = {
  top = '3px',
  left = '0.5cell',
  right = '0.5cell',
  bottom = 0,
}

return config
