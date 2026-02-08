local utils = require("lang.utils")

local M = {}

--- Downloads any necessary tools to work with Lua, if they haven't been
--- downloaded yet, and configures them. Should run at most once per session.
function M.setup_tools()

	--- LSP --------------------------------------------------------------------
	utils.mason_install("lua-language-server")
	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = {
					disable = { "trailing-space" },
					globals = { "vim" },
				},
				workspace = {
					-- Make the server aware of these APIs for autocomplete
					library = {
						-- Neovim's api (vim.*)
						vim.env.VIMRUNTIME,
						-- luarocks libs (luv for async IO and busted for TDD)
						"${3rd}/luv/library",
						"${3rd}/busted/library",
						-- Lazy plugins
						vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua",
						vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/lua",
						-- Other libs
						"/home/raphael/data/code/3rd-party/wezterm-types",
					},
				},
			},
		},
		capabilities = require("cmp_nvim_lsp").default_capabilities(),
	})
	vim.lsp.enable("lua_ls")


	--- DAP --------------------------------------------------------------------
	local dap = require("dap")

	dap.adapters.nlua = function(callback, config)
		callback({ type = "server", host = config.host, port = config.port })
	end
	dap.configurations.lua = {
		{
			type = "nlua",
			request = "attach",
			name = "Attach to a running Neovim instance",
			host = function()
				return "127.0.0.1"
			end,
			port = function()
				return tonumber(vim.fn.input("Port: ", "54231"))
			end,
		},
	}


	--- Formatter and linter ---------------------------------------------------
	local null_ls = require("null-ls")
	utils.mason_install("stylua", function()
		null_ls.register({
			null_ls.builtins.formatting.stylua,
		})
	end)
end

--- Config settings specific for Lua, such as vim.opts and keymaps.
--- @param bufnr number The ID of the buffer to apply these settings to.
function M.setup_buffer(bufnr)
	utils.once("lang.lua.setup_tools", M.setup_tools)

	--- Lang-specific options --------------------------------------------------
	vim.bo[bufnr].tabstop = 3
	vim.bo[bufnr].expandtab = false

end

return M
