local buffer_group = vim.api.nvim_create_augroup("buf_cmds", { clear = true })


vim.api.nvim_create_autocmd("LspAttach", {
	pattern = "*",
	group = buffer_group,
	desc = "Disables native color highlighting (I prefer using a plugin)",
	callback = function()
		vim.lsp.document_color.enable(false)
	end,
})


vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "lua/config/*.lua",
	group = buffer_group,
	desc = "Hot-reloads any changed Lua module.",
	callback = function(args)
		local module_name = (vim.loop.cwd() .. "/" .. args.file)
			:gsub("^" .. vim.fn.stdpath("config") .. "/lua/", "")
			:gsub("%.lua$", "")
			:gsub("/", ".")
			:gsub("%.init$", "")
		package.loaded[module_name] = nil
		require(module_name)
	end,
})


--
-- Only enable relativenumber on a focused window not in insert mode
--
local insert_mode
local except_buffers = { 'help', 'NvimTree' }
vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
	pattern = "*",
	group = buffer_group,
	desc = "Disable relative line numbers when entering insert mode or leaving window.",
	callback = function(autocmd)
		if not vim.tbl_contains(except_buffers, vim.bo.filetype) then
			if autocmd.event == "InsertEnter" then
				insert_mode = true
			end
			vim.opt.relativenumber = false
		end
	end,
})
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
	pattern = "*",
	group = buffer_group,
	desc = "Only enable relative line numbers on focused window when not in Insert mode.",
	callback = function(autocmd)
		if not vim.tbl_contains(except_buffers, vim.bo.filetype) then
			if autocmd.event == "InsertLeave" then
				insert_mode = false
			end
			vim.opt.relativenumber = not insert_mode
		end
	end,
})


--
-- Dynamic highlight for trailing spaces (only when out of insert mode).
--
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*",
	group = buffer_group,
	desc = "Matches trailing spaces and creates a highlight group for them.",
	callback = function()
		vim.fn.matchadd("TrailingWhitespace", "\\s\\+$")
	end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
	pattern = "*",
	group = buffer_group,
	desc = "Disables trailing space highlighting when in Insert mode.",
	callback = function()
		vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "Whitespace" })
	end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	group = buffer_group,
	desc = "Enables trailing spaces highlighting when out of Insert mode.",
	callback = function()
		vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "TrailingWhitespaceStyle" })
	end,
})
