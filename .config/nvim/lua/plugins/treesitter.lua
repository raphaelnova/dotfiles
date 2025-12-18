return {
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
}
