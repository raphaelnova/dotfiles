local ns = vim.api.nvim_create_namespace("FoldDecor")

-- Highlight fold indicators
vim.api.nvim_set_hl(0, "FoldExtMarks", { fg = "#555555", bg = "NONE" })

vim.fn.sign_define("FoldSign", { text = "+", texthl="FoldExtMarks" })

--- Get the total length of a buffer line, taking into account
--- extmarks and chars that span multiple columns like <tab>
--- @param buf number The buffer identifier
--- @param lnum number The number of the line to measure
--- @return number
local get_total_width = function(buf, lnum)
	local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1] or ""
	local length = vim.fn.strdisplaywidth(line)

	-- (buf, ns_id (-1 = all), start={line, col=0}, end={line, col=last}, opts)
	local extmarks = vim.api.nvim_buf_get_extmarks(buf, -1, { lnum - 1, 0 }, { lnum - 1, -1 }, { details = true })

	for _, mark in ipairs(extmarks) do
		local details = mark[4] -- [extmark_id, row, col, details]
		if details ~= nil and details.virt_text and details.virt_text_pos == "inline" then
			local txt = table.concat(vim.tbl_map(function(e)
				return e[1]
			end, details.virt_text))
			length = length + vim.fn.strdisplaywidth(txt)
		end
	end

	return length
end

--- Draw fold indicators
--- @param buf number Buffer ID
--- @param topline number First line visible in the window
--- @param bottomline number Last line visible in the window
local draw_fold_indicators = function(buf, topline, bottomline)
	if vim.bo[buf].buftype ~= "" then
		return
	end

	vim.fn.sign_unplace("foldsigns")

	local lnum = topline

	while lnum <= bottomline do
		if vim.fn.foldclosed(lnum) == lnum then
			local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1] or ""
			local indent = line:match("^%s*") or ""
			local indent_cols = vim.fn.strdisplaywidth(indent)

			-- Prefix placed over indentation
			-- vim.api.nvim_buf_set_extmark(buf, ns, lnum - 1, 0, {
			-- 	virt_text = { { "[+] ", "FoldExtMarks" } },
			-- 	virt_text_win_col = math.max(indent_cols - 4, 0),
			-- 	hl_mode = "combine",
			-- 	priority = 200,
			-- 	ephemeral = true,
			-- })
			vim.fn.sign_place(lnum, "foldsigns", "FoldSign", vim.fn.bufname("%"), {
				lnum = lnum,
				priority = 10,
			})

			-- Suffix at end-of-line
			vim.api.nvim_buf_set_extmark(buf, ns, lnum - 1, 0, {
				virt_text = { { " ...", "FoldExtMarks" } },
				virt_text_win_col = get_total_width(buf, lnum) + 1,
				hl_mode = "combine",
				priority = 200,
				ephemeral = true,
			})

			-- Skip to first line after this fold's end
			lnum = vim.fn.foldclosedend(lnum) + 1
		else
			lnum = lnum + 1
		end
	end
end

-- Setting a callback for a redraw
vim.api.nvim_set_decoration_provider(ns, {
	on_win = function(_, _, buf, topline, bottomline)
		draw_fold_indicators(buf, topline, bottomline)
	end,
})
