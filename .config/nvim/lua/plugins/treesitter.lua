return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
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
			},
			highlight = { enable = true },
			autotag = { enable = true },
			indent = { enable = true },
			fold = { enable = true },
		})
	end,
}
