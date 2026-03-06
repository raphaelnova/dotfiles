return {
	"mfussenegger/nvim-lint",
	config = function()
		local utils = require("lang.utils")
		local lint = require("lint")

		lint.linters_by_ft = {
			python   = { "flake8" },
			markdown = { "markdownlint-cli2" },
		}

		utils.mason_install("flake8")
		utils.mason_install("markdownlint-cli2")

		vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
