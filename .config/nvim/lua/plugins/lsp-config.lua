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

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = {
							disable = { "trailing-space" },
							globals = { "vim" },
						},
					},
				},
				capabilities = capabilities,
			})
			vim.lsp.enable("lua_ls")

			vim.lsp.config("bashls", { capabilities = capabilities })
			vim.lsp.enable("bashls")

			vim.lsp.config("ts_ls", { capabilities = capabilities })
			vim.lsp.enable("ts_ls")

			vim.lsp.config("pyright", {
				settings = {
					pyright = {
						disableLanguageServices = false,
						disableOrganizeImports = false,
						analysis = {
							inlayHints = {
								callArgumentNames = true,
								variableTypes = true,
							},
						},
					},
					python = {
						analysis = {
							autoImportCompletions = true,
							autoSearchPaths = true,
							diagnosticMode = "workspace", -- openFilesOnly, workspace
							typeCheckingMode = "basic", -- off, basic, strict
							useLibraryCodeForTypes = true,
						},
					},
				},
				single_file_support = true,
			})
			vim.lsp.enable("pyright")

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
				"lua_ls",
				"ts_ls",
				"bashls",
				"pyright",
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
