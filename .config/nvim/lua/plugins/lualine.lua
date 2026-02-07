return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = {
					inactive = { a = { bg = "#161616", fg = "#666666" } },
					normal = {
						a = { bg = "#161616", fg = "#eeeeee" },
						b = { bg = "#161616", fg = "#eeeeee" },
						c = { bg = "#161616", fg = "#eeeeee" },
					},
					-- insert, command, terminal, visual, replace
				},
				section_separators = { left = "", right = "", },
				component_separators = { left = ":", right = ":", },
				disabled_filetypes = { statusline = {}, winbar = {}, },
				ignore_focus = { "NvimTree" },
				always_divide_middle = true,
				globalstatus = false,
				refresh = { -- in ms
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "filename" },
				lualine_c = { },

				lualine_x = { },
				lualine_y = {
					{
						"diagnostics",
						symbols = {
							error = "✖ ",
							warn = "▲ ",
							info = "⚑ ",
							hint = "✚ ",
						},
					},
				},
				lualine_z = { "lsp_status" },
			},
			inactive_sections = {
				lualine_a = { "filename" },
				lualine_b = { },
				lualine_c = { },

				lualine_x = { },
				lualine_y = { },
				lualine_z = { },
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		})
	end,
}
