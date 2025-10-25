local function custom_highlights()
	-- Remove background from folds
	vim.api.nvim_set_hl(0, "Folded", { bg = "NONE" })

	-- QuickFix current item
	vim.api.nvim_set_hl(0, "QuickFixLine", { bg = "#111111" })

	-- Fade out inlay hints a little more
	vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#555555", bg = "NONE" })

	-- Disable graying out of whole blocks of unused code
	vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { link = "NONE" })

	-- Search highlights (incremental, active item and all found items)
	vim.api.nvim_set_hl(0, "IncSearch", { fg = "#000000", bg = "#FFFF00", reverse = false })
	vim.api.nvim_set_hl(0, "CurSearch", { fg = "#FFFFFF", bg = "#008040", reverse = false })
	vim.api.nvim_set_hl(0, "Search",    { fg = "#FFFFFF", bg = "#008000", reverse = false })

	-- listchars
	vim.api.nvim_set_hl(0, "NonText",    { fg = "#282855", reverse = false })
	vim.api.nvim_set_hl(0, "Whitespace", { fg = "#282855", reverse = false })

	--
	-- Highlight trailing spaces only out of insert mode
	--
	vim.api.nvim_set_hl(0, "TrailingWhitespaceStyle", { fg = "#FF00FF", underline = false, reverse = false })
	vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "TrailingWhitespaceStyle" })

	-- Match trailing spaces and highlight them
	vim.api.nvim_create_autocmd("BufWinEnter", {
		callback = function()
			vim.fn.matchadd("TrailingWhitespace", "\\s\\+$")
		end,
	})

	-- Toggle trailing spaces highilighting, disabled when in Insert mode
	vim.api.nvim_create_autocmd("InsertEnter", {
		callback = function()
			vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "Whitespace" })
		end,
	})
	vim.api.nvim_create_autocmd("InsertLeave", {
		callback = function()
			vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "TrailingWhitespaceStyle" })
		end,
	})
	--
	-- End highlight trailing spaces
	--
end

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
			custom_highlights()
			add_colorscheme("catppuccin-mocha")
			add_colorscheme("catppuccin-macchiato")
			add_colorscheme("catppuccin-frappe")
			add_colorscheme("catppuccin-latte")

			vim.cmd.colorscheme("catppuccin-mocha")
		end
	},
	{
		"xeind/nightingale.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			custom_highlights()
			add_colorscheme("nightingale")
		end
	},
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			custom_highlights()
			add_colorscheme("nightfox")
			add_colorscheme("dayfox")
			add_colorscheme("dawnfox")
			add_colorscheme("nordfox")
			add_colorscheme("terafox")
			add_colorscheme("carbonfox")
		end
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			custom_highlights()
			add_colorscheme("kanagawa-wave")
			add_colorscheme("kanagawa-dragon")
			add_colorscheme("kanagawa-lotus")
		end
	},
}
