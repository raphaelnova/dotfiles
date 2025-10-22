local keymaps = require("config.keymaps")

return {
	{
		"tpope/vim-fugitive",
		config = keymaps.git,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
			keymaps.gitsigns()
		end,
	},
}
