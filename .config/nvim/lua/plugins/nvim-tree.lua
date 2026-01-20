return {
	"nvim-tree/nvim-tree.lua",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local function open_win_config_func()
			local scr_w = vim.opt.columns:get()
			local scr_h = vim.opt.lines:get()
			local tree_w = 120
			local tree_h = math.floor(tree_w * scr_h / scr_w)
			return {
				border = "single",
				relative = "editor",
				width = tree_w,
				height = tree_h,
				col = (scr_w - tree_w) / 2,
				row = (scr_h - tree_h) / 2,
			}
		end
		-- :h nvim-tree-quickstart-help
		require("nvim-tree").setup({
			hijack_netrw = true,
			auto_reload_on_write = true,
			git = {
				enable = false,
			},
			view = {
				float = {
					enable = true,
					open_win_config = open_win_config_func,
				},
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
