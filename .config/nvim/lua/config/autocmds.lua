local buffer_group = vim.api.nvim_create_augroup("buf_cmds", { clear = true })

--
-- Detect Java projects on startup, cache metadata, and pre-warm JDTLS.
--
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	group = buffer_group,
	desc = "Pre-warm JDTLS and load project metadata when CWD is a Java project.",
	callback = function()
		local project = require("lang.java.project")

		local cwd = vim.fn.getcwd()
		if not project.detect(cwd) then
			return
		end

		-- Parse pom.xml and store project info globally so any module can read it.
		local info = project.parse_pom(cwd) or {}

		-- root = deepest package prefix common to all classes (e.g. "com.example.app")
		local src_root = cwd .. "/src/main/java"
		if vim.fn.isdirectory(src_root) == 1 then
			local root_pkg = project.find_root_package(src_root)
			info.root_package = root_pkg ~= "" and root_pkg or nil
		end

		vim.g.java_project = info

		local label = (info.artifact_id or vim.fn.fnamemodify(cwd, ":t"))
			.. (info.java_version and (" · Java " .. info.java_version) or "")
		vim.notify("[java] " .. label, vim.log.levels.INFO)

		-- Pre-warm JDTLS: create a hidden, unlisted Java buffer whose "path" lives
		-- inside the project root so JDTLS discovers the correct root_dir via
		-- pom.xml. Setting `filetype = "java"` fires the FileType autocmd
		-- registered by `vim.lsp.enable("jdtls")`, which starts the language server.
		-- The buffer is never shown but stays alive, keeping the client attached.
		local buf = vim.api.nvim_create_buf(false, false)
		vim.api.nvim_buf_set_name(buf, cwd .. "/.jdtls_warmup.java")
		vim.bo[buf].bufhidden = "hide"
		vim.bo[buf].filetype = "java"
	end,
})

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
local except_buffers = { "help", "NvimTree", "Outline" }
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
