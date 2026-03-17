local utils = require("lang.utils")

local M = {}

--- Downloads any necessary tools to work with Java, if they haven't been
--- downloaded yet, and configures them. Should run at most once per session.
function M.setup_tools()
	utils.mason_install("java-test")
	utils.mason_install("java-debug-adapter")
	utils.mason_install("google-java-format", function()
		require("conform").formatters_by_ft.java = { "google-java-format" }
	end)
end

--- Config settings specific for Java, such as vim.opts and keymaps.
--- @param bufnr number The ID of the buffer to apply these settings to.
function M.setup_buffer(bufnr)
	utils.once("lang.java.setup_tools", M.setup_tools)

	vim.bo[bufnr].tabstop = 4

	require("config.keymaps").java(bufnr)

	vim.lsp.codelens.refresh()
	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = { "*.java" },
		callback = function()
			pcall(vim.lsp.codelens.refresh)
			pcall(vim.diagnostic.setqflist, { open = false })
		end,
	})

	-- Commented since I'm using nvim-java now
	-- require("lang.java.jdtls").attach()

	--- User commands (buffer-local) -------------------------------------------
	-- local jdtls = require("jdtls")
	-- vim.api.nvim_buf_create_user_command(bufnr, "JdtUpdateConfig", jdtls.update_project_config, {})
	-- vim.api.nvim_buf_create_user_command(bufnr, "JdtBytecode", jdtls.javap, {})
	-- vim.api.nvim_buf_create_user_command(bufnr, "JdtShell", jdtls.jshell, {})
	-- vim.api.nvim_buf_create_user_command(bufnr, "JdtCompile", function(opts)
	-- 	jdtls.compile(opts.args)
	-- end, {
	-- 	nargs = "?",
	-- 	complete = function(_, _, _)
	-- 		return jdtls._complete_compile()
	-- 	end,
	-- })
end

return M
