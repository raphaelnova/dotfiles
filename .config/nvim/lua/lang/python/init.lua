local utils = require("lang.utils")

local M = {}

function M.setup(bufnr)
	vim.bo[bufnr].tabstop = 4

	-- Treesitter parser
	utils.ts_install("python")

	-- LSP
	local lsp_name = "pyright"

	utils.mason_install(lsp_name)

	-- local lspconfig = require("lspconfig")
	-- lspconfig[lsp_name].setup({
	-- 	on_attach = function(client, bufnr)
	-- 		local opts = { buffer = bufnr }
	-- 		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	-- 		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	-- 	end,
	-- })
	vim.lsp.config(lsp_name, {
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
	vim.lsp.enable(lsp_name)

	-- DAP
	do
		local dap_name = "debugpy"

		utils.mason_install(dap_name)

		local dap = require("dap")
		dap.adapters.python = {
			type = "executable",
			command = "mason.get_package(lsp_name):get_install_path() .. '/venv/bin/python",
			args = { "-m", "debugpy.adapter" },
		}
		dap.configurations.python = {
			type = "python",
			request = "launch",
			name = "Run file",
			program = "${file}",
		}
	end

	-- Formatter and linter
	utils.mason_install_then({ "black", "flake8" }, function()
		print("All packages installed. Fired callback. Registering null-ls sources.")
		local null_ls = require("null-ls")
		null_ls.register({
			null_ls.builtins.formatting.black.with({
				filetypes = { "python" },
			}),
			require("none-ls.diagnostics.flake8").with({
				filetypes = { "python" },
				prefer_local = ".venv/bin",
			}),
		})
	end)

	-- Which Key
	utils.try_with("which-key", function(whichkey)
		whichkey.add({
			{ "<leader>d", buffer = bufnr, group = "debug" },
			{ "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<CR>", buffer = bufnr, desc = "Toggle breakpoint" },
			{ "<leader>dc", "<cmd>lua require('dap').continue()<CR>", buffer = bufnr, desc = "Continue" },
		})
	end)
end

return M
