return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		-- dependencies = {
		-- 	"windwp/nvim-ts-autotag",
		-- },
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter")

			treesitter.install({
				"awk",
				"bash",
				"css",
				"gitignore",
				"haskell",
				"html",
				"javascript",
				"json",
				"markdown",
				"markdown_inline",
				"query",
				"typescript",
				"sql",
				"vim",
				"vimdoc",
				"yaml",
			})

			local ignore_filetypes = {
				"checkhealth",
				"lazy",
				"mason",
				"NvimTree",
			}

			local augroup = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = augroup,
				desc = "Enable treesitter.",
				callback = function(ev)
					if vim.tbl_contains(ignore_filetypes, ev.match) then
						return
					end

					local buf = ev.buf
					local lang = vim.treesitter.language.get_lang(ev.match) or ev.match

					treesitter.install({ lang }):await(function(err)
						if err then
							vim.notify("Treesitter failed to install parser for " .. lang .. ". Error: " .. err)
							return
						end
						pcall(vim.treesitter.start, buf, lang)
						vim.opt.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
						vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
						vim.opt.foldmethod = "expr"
					end)
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = "VeryLazy",
		branch = "main",
		keys = {
			{
				"[f",
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
				end,
				desc = "Go to start of previous function",
				mode = { "n", "x", "o" },
			},
			{
				"]f",
				function()
					require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
				end,
				desc = "Go to start of next function",
				mode = { "n", "x", "o" },
			},
			{
				"[F",
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
				end,
				desc = "Go to end of previous function",
				mode = { "n", "x", "o" },
			},
			{
				"]F",
				function()
					require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
				end,
				desc = "Go to end of next function",
				mode = { "n", "x", "o" },
			},
			{
				"[a",
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.outer", "textobjects")
				end,
				desc = "Go to previous argument",
				mode = { "n", "x", "o" },
			},
			{
				"]a",
				function()
					require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.outer", "textobjects")
				end,
				desc = "Go to next argument",
				mode = { "n", "x", "o" },
			},
			{
				"[A",
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_end("@parameter.outer", "textobjects")
				end,
				desc = "Go to previous argument's end",
				mode = { "n", "x", "o" },
			},
			{
				"]A",
				function()
					require("nvim-treesitter-textobjects.move").goto_next_end("@parameter.outer", "textobjects")
				end,
				desc = "Go to next argument's end",
				mode = { "n", "x", "o" },
			},
			{
				"[s",
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_start("@block.outer", "textobjects")
				end,
				desc = "Go to previous block",
				mode = { "n", "x", "o" },
			},
			{
				"]s",
				function()
					require("nvim-treesitter-textobjects.move").goto_next_start("@block.outer", "textobjects")
				end,
				desc = "Go to next block",
				mode = { "n", "x", "o" },
			},
			{
				"[S",
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_end("@block.outer", "textobjects")
				end,
				desc = "Go to previous block's end",
				mode = { "n", "x", "o" },
			},
			{
				"]S",
				function()
					require("nvim-treesitter-textobjects.move").goto_next_end("@block.outer", "textobjects")
				end,
				desc = "Go to next block's end",
				mode = { "n", "x", "o" },
			},
			{
				"gan",
				function()
					require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
				end,
				desc = "Swap next argument",
			},
			{
				"gap",
				function()
					require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
				end,
				desc = "Swap previous argument",
			},
		},

		opts = {
			move = {
				enable = true,
				set_jumps = true,
			},
			swap = {
				enable = true,
			},
		},
	},
}
