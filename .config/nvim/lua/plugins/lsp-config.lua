return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.lsp.config("bashls", { capabilities = capabilities })
			vim.lsp.enable("bashls")

			vim.lsp.config("ts_ls", { capabilities = capabilities })
			vim.lsp.enable("ts_ls")

			vim.lsp.config("lemminx", { capabilities = capabilities })
			vim.lsp.enable("lemminx")

			vim.lsp.config("markdown_oxide", {
				capabilities = vim.tbl_deep_extend("force", capabilities, {
					workspace = {
						didChangeWatchedFiles = {
							dynamicRegistration = false,
						},
					},
				})
			})
			vim.lsp.enable("markdown_oxide")

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
				"lemminx",
			},
			automatic_enable = {
				exclude = { "jdtls" },
			},
		},
	},
	-- {
	-- 	"mfussenegger/nvim-jdtls",
	-- 	branch = "master",
	-- 	dependencies = { "mfussenegger/nvim-dap" },
	-- },
	-- {
	-- 	"JavaHello/spring-boot.nvim",
	-- 	enabled = false,
	-- },
	{
		"nvim-java/nvim-java",
		-- ft = { "java" },
		dependencies = {
			"nvim-java/spring-boot.nvim",
		},
		config = function()
			require("java").setup()
			vim.lsp.enable('jdtls')

			-- spring-boot.nvim registers a FileType autocmd that starts Spring Boot LS
			-- unconditionally. Replace it with a version that checks pom.xml first.
			local project = require("lang.java.project")
			local function is_spring_boot_project(bufnr)
				local fname = vim.api.nvim_buf_get_name(bufnr)
				local root = vim.fs.root(fname, { "pom.xml" })
				return root ~= nil and project.is_spring_boot(root)
			end

			local acs = vim.api.nvim_get_autocmds({ group = "spring_boot_ls", event = "FileType" })
			if #acs > 0 and acs[1].callback then
				local orig = acs[1].callback
				vim.api.nvim_create_augroup("spring_boot_ls", { clear = true })
				vim.api.nvim_create_autocmd("FileType", {
					group = "spring_boot_ls",
					pattern = { "java", "yaml", "jproperties" },
					desc = "Spring Boot Language Server (Spring Boot projects only)",
					callback = function(e)
						if not is_spring_boot_project(e.buf) then return end
						orig(e)
					end,
				})
			end
		end,
	},
}
