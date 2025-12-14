return {
	"nvim-tree/nvim-tree.lua",
	config = function()
		-- :h nvim-tree-quickstart-help
		require("nvim-tree").setup({
			hijack_netrw = true,
			auto_reload_on_write = true,
			git = {
				enable = false,
			},
			view = {
				width = {}, -- dynamic based on longest line
			},
			renderer = {
				group_empty = true,
			},
			filters = {
				custom = {
					".git",
					".mvn",
					".settings",
					".classpath",
					".factorypath",
					".project",
					".vscode",
					".mypy_cache",
					"__pycache__",
					".venv",
					"venv",
				},
			},
		})

		-- vim.api.nvim_set_hl(0, "NvimTreeFolderName",	      { link = "NvimTreeNormal" })
		-- vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName",  { link = "NvimTreeFolderName" })
		-- vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { link = "NvimTreeFolderName" })
		-- vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderIcon", { fg = "#666666" })
		-- vim.api.nvim_set_hl(0, "NvimTreeClosedFolderIcon", { fg = "#666666" })

		require("config.keymaps").nvim_tree()
	end,
}
