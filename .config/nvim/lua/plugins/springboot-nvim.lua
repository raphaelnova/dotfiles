return {
	"elmcgill/springboot-nvim",
	enabled = false,
	dependencies = {
		"neovim/nvim-lspconfig",
		"mfussenegger/nvim-jdtls",
	},
	config = function()
		require("springboot-nvim").setup()
		require("config.keymaps").springboot()
	end,
}
