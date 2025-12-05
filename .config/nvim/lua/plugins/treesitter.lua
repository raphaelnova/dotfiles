return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	build = ":TSUpdate",
	config = function()
		---@diagnostic disable [missing-fields]
		require("nvim-treesitter.configs").setup({
			auto_install = true,
			ensure_installed = {
				"awk",
				"bash",
				"css",
				"gitignore",
				"haskell",
				"html",
				"java",
				"javascript",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"typescript",
				"sql",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
			},
			highlight = { enable = true },
			autotag = { enable = true },
			indent = { enable = true },
			fold = { enable = true },
		})
	end,
}
