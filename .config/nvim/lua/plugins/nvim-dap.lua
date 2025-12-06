return {
	{
		-- This is a Debug Adapter Protocol **client** that will connect nvim
		-- debug tools to a debug adapter that will bridge to the lang server
		-- (java-debug-adapter running as a jdtls plugin in this case)
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",             -- async IO (what for?)
			"theHamsta/nvim-dap-virtual-text",   -- shows var values while debugging
			"jbyuki/one-small-step-for-vimkind", -- debug nvim plugins
			"mfussenegger/nvim-dap-python",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup({
				expand_lines = true,
				controls = { enabled = false },
				layouts = {
					-- Just the scope variables and the console
					{
						elements = {
							{ id = "scopes", size = 0.5 },
							{ id = "console", size = 0.5 },
							-- breakpoints, stacks, watches and repl
							-- :h dapui.elements
						},
						size = 12, -- height in lines
						position = "bottom",
					},
					-- You can add more panes:
					-- { elements = { ... }, position = "left" }
					-- :h dapui.Config.layout
				},
			})

			dap.listeners.before.launch.dapui_config = dapui.open

			-- TODO: Find out why these events don't work. Events and requests:
			-- https://microsoft.github.io/debug-adapter-protocol/specification
			dap.listeners.before.event_terminated.dapui_config = function()
				print("event 'terminated'")
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				print("event 'exited'")
				dapui.close()
			end

			-- :help sign_define
			vim.fn.sign_define("DapBreakpoint", {
				text = "◆", -- \u25c6
				texthl = "DapBreakpoint",
			})
			vim.fn.sign_define("DapStopped", {
				text = "➡", -- \u27a1
				texthl = "DapUIBreakpointsCurrentLine",
			})

			require("nvim-dap-virtual-text").setup({})

			require("config.keymaps").dap()
		end,
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		config = function()
			require("mason-nvim-dap").setup({
				-- Gotta call them by their nvim_dap name,
				-- not their Mason name. See:
				-- https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
				ensure_installed = {
					"javadbg",  -- "java-debug-adapter"
					"javatest", -- "java-test"
					"bash",     -- "bash-debug-adapter"
				},
			})
		end,
	},
}
