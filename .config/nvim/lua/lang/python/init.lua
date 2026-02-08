local utils = require("lang.utils")

local M = {}

--- Downloads any necessary tools to work with Python, if they haven't been
--- downloaded yet, and configures them. Should run at most once per session.
function M.setup_tools()

	--- LSP --------------------------------------------------------------------
	utils.mason_install("pyright")

	-- Extending:
	-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/pyright.lua
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


	--- DAP --------------------------------------------------------------------
	utils.mason_install("debugpy")
	require("dap-python").setup("debugpy-adapter")


	--- Formatter and linter ---------------------------------------------------
	local null_ls = require("null-ls")
	utils.mason_install("black", function()
		null_ls.register({
			null_ls.builtins.formatting.black.with({
				filetypes = { "python" },
			})
		})
	end)
	utils.mason_install("flake8", function()
		null_ls.register({
			require("none-ls.diagnostics.flake8").with({
				filetypes = { "python" },
				prefer_local = ".venv/bin",
			})
		})
	end)
end

--- Config settings specific for Python, such as vim.opts and keymaps.
--- @param bufnr number The ID of the buffer to apply these settings to.
function M.setup_buffer(bufnr)
	utils.once("lang.python.setup_tools", M.setup_tools)

	--- Lang-specific options --------------------------------------------------
	vim.bo[bufnr].tabstop = 4

	--- Keymaps ----------------------------------------------------------------
	require("config.keymaps").python(bufnr)
end

return M
