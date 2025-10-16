return {
	{
		"tpope/vim-fugitive",
		keys = require("config.keymaps").git(),
	},
	{
		"lewis6991/gitsigns.nvim",
		keys = require("config.keymaps").gitsigns(),
		config = function()
			require("gitsigns").setup()
		end,
	},
}
