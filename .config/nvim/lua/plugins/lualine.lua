return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "catppuccin",
				section_separators = { -- remove to default to   (\ue0b0, \ue0b2)
					left = "",
					right = "",
				},
				component_separators = { -- remove to default to   (\ue0b1, \ue0b3)
					left = ":",
					right = ":",
				},
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = { "NvimTree" },
				always_divide_middle = true,
				global_status = false,
				refresh = { -- in ms
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },

					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },

					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				winbar = {},
				inactive_winbar = {},
				extensions = {},
			},
		})
	end,
}
