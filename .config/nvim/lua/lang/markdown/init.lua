local M = {}

--- Expands `refl` to [text][ref]. On exit appends the `[ref]: <url>` definition
--- at end of file and moves the cursor there so the URL can be typed immediately.
--- Use <C-o> to return.
local function setup_snippets()
	local ok, ls = pcall(require, "luasnip")
	if not ok then
		return
	end

	local s = ls.snippet
	local i = ls.insert_node
	local t = ls.text_node
	local events = require("luasnip.util.events")

	-- Temporary storage for the ref value captured when leaving node 2.
	-- Keyed by buffer to be safe across concurrent snippet sessions.
	local pending = {}

	ls.add_snippets("markdown", {
		s({ trig = "refl", desc = "Reference link: [text][ref] — appends [ref]: at end of file" }, {
			t("["),
			i(1, "text"),
			t("]["),
			i(2, "ref"),
			t("]"),
		}, {
			callbacks = {
				-- Capture ref value just before leaving the ref node.
				[2] = {
					[events.leave] = function(node)
						local ref = node:get_text()[1]
						if ref and ref ~= "" then
							pending.ref = ref
							pending.bufnr = vim.api.nvim_get_current_buf()
						end
					end,
				},
				-- On full snippet exit: append the definition line and jump there.
				[-1] = {
					[events.leave] = function()
						local ref = pending.ref
						local bufnr = pending.bufnr
						pending = {}

						if not ref or ref == "" then
							return
						end

						vim.schedule(function()
							if not vim.api.nvim_buf_is_valid(bufnr) then
								return
							end

							-- Skip if a definition for this ref already exists.
							local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
							local pattern = "^%[" .. vim.pesc(ref) .. "%]:"
							for _, line in ipairs(lines) do
								if line:match(pattern) then
									return
								end
							end

							-- Save current position so <C-o> brings the user back.
							vim.cmd("normal! m'")

							-- Append a blank separator + the definition stub.
							local last = vim.api.nvim_buf_line_count(bufnr)
							local def = "[" .. ref .. "]: "
							vim.api.nvim_buf_set_lines(bufnr, last, last, false, { "", def })

							-- Place cursor right after ": " ready to type the URL.
							vim.api.nvim_win_set_cursor(0, { last + 2, #def })
						end)
					end,
				},
			},
		}),
	}, { key = "markdown_reflink" })
end

--- Jumps between a reference link and its definition.
local function jump_ref_link()
	local line = vim.api.nvim_get_current_line()
	local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- convert to 1-indexed

	-- Case 1: cursor line IS a definition  →  jump to a usage.
	local def_ref = line:match("^%[([^%]]+)%]:")
	if def_ref then
		local escaped = vim.fn.escape(def_ref, [[\[]^$.*?+(){}|]])
		local found = vim.fn.search("\\[" .. escaped .. "\\]", "w")
		if found == 0 then
			vim.notify("No usage found for [" .. def_ref .. "]", vim.log.levels.WARN)
		end
		return
	end

	-- Case 2: cursor is inside a [text][ref] link  →  jump to its definition.
	local offset = 1
	while true do
		local ms, _, text, ref = line:find("%[([^%]]*)%]%[([^%]]*)%]", offset)
		if not ms then
			break
		end

		local me = ms + #("[" .. text .. "][" .. ref .. "]") - 1
		if cursor_col >= ms and cursor_col <= me then
			local escaped = vim.fn.escape(ref, [[\[]^$.*?+(){}|]])
			local found = vim.fn.search("^\\[" .. escaped .. "\\]:", "w")
			if found == 0 then
				vim.notify("No definition found for [" .. ref .. "]", vim.log.levels.WARN)
			end
			return
		end

		offset = ms + 1
	end

	vim.notify("No reference link under cursor", vim.log.levels.INFO)
end

function M.setup_buffer(bufnr)

	-- LSP hover (or any other unlisted buffer)
	if vim.fn.getbufinfo(bufnr)[1].listed == 0 then
		vim.opt.conceallevel = 2
		return
	end

	vim.opt.conceallevel = 0

	local utils = require("lang.utils")
	utils.once("markdown_snippets", setup_snippets)

	vim.keymap.set("n", "gd", jump_ref_link, {
		buffer = bufnr,
		desc = "Markdown: jump between reference link and its definition",
	})
end

return M
