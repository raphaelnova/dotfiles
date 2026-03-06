return {
	"stevearc/conform.nvim",
	config = function()
		local utils = require("lang.utils")
		require("conform").setup({
			formatters_by_ft = {
				css = { "prettier" },
				html = { "prettier" },
				javascript = { "prettier" },
				json = { "prettier" },
				markdown = { "markdownlint-cli2", "prettier" },
				typescript = { "prettier" },
				xml = { "xmllint" },
				yaml = { "prettier" },
			},
			formatters = {
				xmllint = {
					env = {
						XMLLINT_INDENT = "  ",
					},
					args = { "--format", "$FILENAME" },
				},
				["markdownlint-cli2"] = {
					args = { "$FILENAME", "--fix" },
					exit_codes = { 0, 1 },
				},
			},
		})
		utils.mason_install("prettier")

		vim.api.nvim_create_autocmd({ "BufNew", "BufReadPost" }, {
			group = vim.api.nvim_create_augroup("conform.nvim", { clear = true }),
			callback = function()
				vim.bo.formatexpr = "v:lua.require'conform'.formatexpr()"
			end,
		})
	end,
}
