local function add_colorscheme(name)
	local colorschemes = vim.g.colorschemes
	table.insert(colorschemes, name)
	vim.g.colorschemes = colorschemes
end

vim.g.colorschemes = {}
return {
	{
		"catppuccin/nvim",
		lazy = false,
		priority = 1000,
		config = function()
			add_colorscheme("catppuccin-mocha")
			add_colorscheme("catppuccin-macchiato")
			add_colorscheme("catppuccin-frappe")
			add_colorscheme("catppuccin-latte")

			vim.api.nvim_set_hl(0, "TrailingWhitespace", {})
			vim.api.nvim_set_hl(0, "TrailingWhitespaceStyle", {})
			require("catppuccin").setup({
				color_overrides = {
					-- These change colors by identifier (applies everywhere they are used)
					-- https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/palettes/mocha.lua
					mocha = {
						-- Grays with same luminance as original colors
						base = "#1F1F1F",
						mantle = "#191919",
						surface2 = "#5C5C5C",
						surface1 = "#484848",
						surface0 = "#333333",

						-- My own, doesn't override any existing color
						surfaceN = "#282828",
						fuchsia = "#FF00FF",
					},
				},
				highlight_overrides = {
					-- These assign color identifiers to highlights groups
					mocha = function(cp)
						return {
							--[[
							-- Highlight groups defined by vim syntax
							-- https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups/syntax.lua
							--]]
							Comment = { fg = cp.overlay2 },
							ColorColumn = { bg = cp.mantle },
							CursorColumn = { bg = cp.surfaceN },
							CursorLine = { bg = cp.surfaceN },

							-- Remove background from folds
							Folded = { bg = "NONE" },

							-- QuickFix current item
							QuickFixLine = { bg = "#111111" },

							-- IncSearch = { fg = "#000000", bg = "#FFFF00", reverse = false },
							-- CurSearch = { fg = "#FFFFFF", bg = "#008040", reverse = false },
							-- Search = { fg = "#FFFFFF", bg = "#008000", reverse = false },

							NonText = { fg = cp.surface0, reverse = false },
							Whitespace = { fg = cp.surface0, reverse = false },
							TrailingWhitespaceStyle = { fg = cp.fuchsia, underline = false, reverse = false },
							TrailingWhitespace = { link = "TrailingWhitespaceStyle" },

							-- Disable graying out of whole blocks of unused code
							DiagnosticUnnecessary = { link = "NONE" },

							-- Fade out inlay hints a little more
							LspInlayHint = { fg = cp.surface2, bg = "NONE" },

							--[[
							-- Highlight groups defined by Tree-sitter
							-- https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups/treesitter.lua
							--]]
							["@keyword.conditional.lua"] = { fg = cp.mauve },

							-- Highlight groups defined by the LS (treesitter preferred)
							-- https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups/semantic_tokens.lua
							["@lsp.type.variable"] = {},
						}
					end,
				},
			})

			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
	{
		"xeind/nightingale.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			add_colorscheme("nightingale")
		end,
	},
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			add_colorscheme("nightfox")
			add_colorscheme("dayfox")
			add_colorscheme("dawnfox")
			add_colorscheme("nordfox")
			add_colorscheme("terafox")
			add_colorscheme("carbonfox")
		end,
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			add_colorscheme("kanagawa-wave")
			add_colorscheme("kanagawa-dragon")
			add_colorscheme("kanagawa-lotus")
		end,
	},
}
