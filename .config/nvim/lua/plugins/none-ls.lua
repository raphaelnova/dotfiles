return {
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvimtools/none-ls-extras.nvim", -- for eslint_d
		},
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				-- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md
				sources = {
					-- require("none-ls.diagnostics.eslint_d"),        -- JS
					-- null_ls.builtins.diagnostics.ansiblelint,       -- Ansible
					-- null_ls.builtins.formatting.stylua,             -- Lua
					-- null_ls.builtins.formatting.shfmt.with({        -- Shell/Bash
					-- 	filetypes = { "sh", "bash", },
					-- 	-- Google Style, as seen on patrickvane/shfmt
					-- 	extra_args = { "-i", "2", "-ci" },
					-- }),
					-- null_ls.builtins.formatting.black,              -- Python
					null_ls.builtins.formatting.prettier,           -- Anything else
				},
			})
			require("config.keymaps").none_ls()
		end,
	},
	{
		"jay-babu/mason-null-ls.nvim",
		dependencies = {
			"nvimtools/none-ls.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = nil,
				automatic_installation = true,
				-- ensure_installed = {
				-- 	"ansible-lint",
				-- 	"black",
				-- 	"eslint_d",
				-- 	"google_java_format",
				-- 	"prettier",
				-- 	"shfmt",
				-- 	"stylua",
				-- 	"xmllint",
				-- },
			})
		end,
	},
}
