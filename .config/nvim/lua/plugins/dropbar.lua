return {
	"Bekaboo/dropbar.nvim",
	dependencies = {
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
	},
	lazy = false, -- must be ready before LspAttach fires; event-based loading races
	config = function()
		local sources   = require("dropbar.sources")
		local utils_src = require("dropbar.utils").source

		--- Returns the sub-package suffix for buf's file, relative to
		--- info.root_package. For example, if root is "com.example" and the
		--- file's package is "com.example.project.model", returns "project.model".
		--- Returns "" when the file is directly in the root package, nil otherwise.
		local function current_sub_package(buf, info)
			local path   = vim.api.nvim_buf_get_name(buf)
			local marker = "/src/main/java/"
			local s      = path:find(marker, 1, true)
			if not s then return nil end
			local pkg_path = path:sub(s + #marker):match("^(.+)/[^/]+%.java$")
			if not pkg_path then return nil end
			local pkg    = pkg_path:gsub("/", ".")
			local root   = info.root_package
			if pkg == root then return "" end
			local prefix = root .. "."
			if vim.startswith(pkg, prefix) then
				return pkg:sub(#prefix + 1)
			end
			return nil
		end

		-- For Java buffers: shows root_package (non-interactive) followed by the
		-- sub-package suffix as a selectable symbol whose dropdown lists every
		-- sub-package under root_package. Clicking a sub-package navigates to
		-- the first Java file found in that package.
		-- Falls back to the normal path source when project info is unavailable.
		local java_pkg_source = {
			get_symbols = function(buf, win, cursor)
				local info = vim.g.java_project
				if not (info and info.root_package) then
					return sources.path.get_symbols(buf, win, cursor)
				end

				local DropBarSymbol = require("dropbar.bar").dropbar_symbol_t

				local root_sym = DropBarSymbol:new({
					buf      = buf,
					win      = win,
					name     = info.root_package,
					icon     = " ", -- \uf487
					name_hl  = "DropBarKindPackage",
					icon_hl  = "DropBarIconKindJavaPackage",
					on_click = false,
				})

				local sub_pkg = current_sub_package(buf, info)
				if not sub_pkg or sub_pkg == "" then
					return { root_sym }
				end

				-- Scan live so new packages appear immediately without restarting.
				-- readdir on a typical Java tree is sub-ms; dropbar debounces at 32 ms.
				local root_pkg_dir = info.root_pkg_dir
					or (info.root_dir .. "/src/main/java/" .. info.root_package:gsub("%.", "/"))
				local all_sub_pkgs = require("lang.java.project").scan_packages(root_pkg_dir, "")

				-- Build one sibling symbol per sub-package. `jump` overrides
				-- dropbar_symbol_t:jump() (which requires a LSP range) with a
				-- vim.ui.select picker over the Java classes in that package.
				local siblings    = {}
				local sibling_idx = 1
				for i, sp in ipairs(all_sub_pkgs) do
					local sp_dir = root_pkg_dir .. "/" .. sp:gsub("%.", "/")
					siblings[i] = DropBarSymbol:new({
						buf     = buf,
						win     = win,
						name    = sp,
						icon    = " ",
						name_hl = "DropBarKindPackage",
						icon_hl = "DropBarIconKindJavaPackage",
						jump    = function()
							-- Schedule so the dropbar menu has fully closed first.
							vim.schedule(function()
								local classes = {}
								for _, f in ipairs(vim.fn.readdir(sp_dir)) do
									if f:match("%.java$") then
										local classname, _ = f:gsub("%.java$", "")
										table.insert(classes, classname)
									end
								end
								if #classes == 0 then return end
								vim.ui.select(classes, { prompt = sp .. " › " }, function(choice)
									if choice then
										vim.cmd.edit(sp_dir .. "/" .. choice .. ".java")
									end
								end)
							end)
						end,
					})
					if sp == sub_pkg then sibling_idx = i end
				end

				local sub_sym = DropBarSymbol:new({
					buf         = buf,
					win         = win,
					name        = sub_pkg,
					icon        = "",
					name_hl     = "DropBarKindPackage",
					icon_hl     = "DropBarIconKindPackage",
					siblings    = siblings,
					sibling_idx = sibling_idx,
				})

				return { root_sym, sub_sym }
			end,
		}

		-- For Java buffers: use LSP exclusively — no treesitter fallback.
		-- Treesitter's name_regex captures annotations (@Entity, @Table) and access
		-- modifiers that precede class/method names in Java source, producing
		-- noisy breadcrumbs like "@Entity @Table" instead of "Project".
		-- Behaviour:
		--   · No JDTLS client attached yet  → "…" placeholder
		--   · JDTLS attached, still indexing → "…" placeholder
		--   · JDTLS indexed, cursor in symbol → normal LSP symbol breadcrumbs
		--   · JDTLS indexed, cursor outside symbol → empty (correct)
		local function placeholder(buf, win)
			return {
				require("dropbar.bar").dropbar_symbol_t:new({
					buf      = buf,
					win      = win,
					name     = "…",
					icon     = "",
					on_click = false,
				}),
			}
		end

		local java_sym_source = {
			get_symbols = function(buf, win, cursor)
				local clients = vim.lsp.get_clients({
					bufnr  = buf,
					method = "textDocument/documentSymbol",
				})
				-- No client attached yet — definite "not ready" state.
				if vim.tbl_isempty(clients) then
					return placeholder(buf, win)
				end

				local symbols = sources.lsp.get_symbols(buf, win, cursor)

				-- Track whether this buffer's LSP has ever returned symbols.
				-- Until it does, empty results mean "still indexing", not
				-- "cursor outside any symbol", so keep showing the placeholder.
				-- After the first non-empty result we trust empty = outside symbol.
				if not vim.tbl_isempty(symbols) then
					vim.b[buf].dropbar_java_lsp_ready = true
				elseif not vim.b[buf].dropbar_java_lsp_ready then
					return placeholder(buf, win)
				end

				return symbols
			end,
		}

		require("dropbar").setup({
			icons = {
				kinds = {
					dir_icon = "",
				},
			},
			bar = {
				pick = { pivots = "asdfgjkl" },
				sources = function(buf, win)
					if vim.bo[buf].buftype == "terminal" then
						return { sources.terminal }
					end

					local ft = vim.bo[buf].ft
					if ft == "markdown" then
						return { sources.path, sources.markdown }
					elseif ft == "java" then
						return { java_pkg_source, java_sym_source }
					end

					return {
						sources.path,
						utils_src.fallback({ sources.lsp, sources.treesitter })
					}
				end,
			},
			sources = {
				treesitter = {
					-- Control-flow nodes removed; only structural symbols remain.
					valid_types = {
						"array",            "boolean",        "block_mapping_pair",
						"call",             "class",          "constant",
						"constructor",      "declaration",    "delete",
						"element",          "enum",           "enum_member",
						"event",            "field",          "function",
						"identifier",       "interface",      "keyword",
						"macro",            "method",         "namespace",
						"null",             "number",         "object",
						"operator",         "package",        "pair",
						"property",         "reference",      "rule",
						"rule_set",         "scope",          "section",
						"specifier",        "statement",      "struct",
						"table",            "type",           "type_parameter",
						"unit",             "value",          "variable",
					},
				},
			},
		})

		-- TODO: Review and move these keymaps
		local dropbar_api = require("dropbar.api")
		vim.keymap.set("n", "<Leader>\\", dropbar_api.pick, { desc = "Pick symbols in winbar" })
		vim.keymap.set("n", "[\\", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
		vim.keymap.set("n", "]\\", dropbar_api.select_next_context, { desc = "Select next context" })
	end,
}
