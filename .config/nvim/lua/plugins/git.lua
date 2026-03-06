local keymaps = require("config.keymaps")

return {
	{
		"tpope/vim-fugitive",
		enabled = false,
		config = keymaps.git,
	},
	{
		"lewis6991/gitsigns.nvim",
		enabled = false,
		config = function()
			require("gitsigns").setup()
			keymaps.gitsigns()
		end,
	},
}
