return {
	"elmcgill/springboot-nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"mfussenegger/nvim-jdtls",
	},
	keys = require("config.keymaps").spring_boot(),
	config = function()
		require("springboot-nvim").setup()
	end,
}
