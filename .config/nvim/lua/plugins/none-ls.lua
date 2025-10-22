return {
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvimtools/none-ls-extras.nvim", -- for eslint_d
		},
		config = function()
			local none_ls = require("null-ls") -- using old fork's name, BAU
			none_ls.setup({
				sources = {
					require("none-ls.diagnostics.eslint_d"),        -- JS
					none_ls.builtins.formatting.stylua,	            -- Lua
					none_ls.builtins.formatting.google_java_format, -- Java
					none_ls.builtins.formatting.xmllint,            -- XML
					none_ls.builtins.formatting.black,              -- Python
					none_ls.builtins.formatting.prettier,           -- Anything else
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
				ensure_installed = {
					"black",
					"eslint_d",
					"google_java_format",
					"prettier",
					"stylua",
					"xmllint",
				},
			})
		end,
	},
}
