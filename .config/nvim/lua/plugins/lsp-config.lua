return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"neovim/nvim-lspconfig",
		keys = require("config.keymaps").lsp(),
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.lsp.config("bashls", { capabilities = capabilities })
			vim.lsp.enable("bashls")

			vim.lsp.config("ts_ls", { capabilities = capabilities })
			vim.lsp.enable("ts_ls")

			-- inline type hints (off by default, but toggleable)
			vim.lsp.inlay_hint.enable(false)
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {
				"jdtls",
				"ts_ls",
				"bashls",
			},
			automatic_enable = {
				exclude = { "jdtls" },
			},
		},
	},
	{
		"mfussenegger/nvim-jdtls",
		branch = "master",
		dependencies = { "mfussenegger/nvim-dap" },
	},
}
