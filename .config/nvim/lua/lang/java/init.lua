local utils = require("lang.utils")

local M = {}

--- Downloads any necessary tools to work with Java, if they haven't been
--- downloaded yet, and configures them. Should run at most once per session.
function M.setup_tools()

	--- DAP & tests ------------------------------------------------------------
	utils.mason_install("java-debug-adapter")
	utils.mason_install("java-test")


	--- Formatter and linter ---------------------------------------------------
	local null_ls = require("null-ls")
	utils.mason_install("google-java-format", function()
		null_ls.register({
			null_ls.builtins.formatting.google_java_format,
		})
	end)
	-- Local install, no Mason here
	null_ls.register({
		null_ls.builtins.formatting.xmllint,
	})
end

--- Config settings specific for Java, such as vim.opts and keymaps.
--- @param bufnr number The ID of the buffer to apply these settings to.
function M.setup_buffer(bufnr)
	utils.once("lang.java.setup_tools", M.setup_tools)

	--- Lang-specific options --------------------------------------------------
	vim.bo[bufnr].tabstop = 4


	--- LSP --------------------------------------------------------------------
	require("lang.java.jdtls").attach()
end

return M
