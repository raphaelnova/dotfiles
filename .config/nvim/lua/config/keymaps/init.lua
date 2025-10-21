vim.g.mapleader = "ç"
vim.g.maplocalleader = "ç"

local M = {}
local f = require("config.keymaps.functions")

---A keymap table used by lazy.nvim to load keymaps after a plugin
---See https://lazy.folke.io/spec/lazy_loading#%EF%B8%8F-lazy-key-mappings
---@class LazyKeysSpec
---@field [1] string lhs (key sequence)
---@field [2] string|function rhs (command to execute)
---@field mode string|string[]? Mode to assign the keymap to (defaults to "n")
---@field desc string? A sentence to describe the keymap
---@field silent boolean? Don't echo the command to the command-line
---@field ft string|string[]? Filetype for which this keymap is active

---Reads a list of LazyKeysSpecs and calls vim.keymap.set on them
---@param specList LazyKeysSpec[]
function M.evalLazyKeysSpecs(specList)
	for _, keys in ipairs(specList) do
		vim.keymap.set(keys.mode, keys[1], keys[2], { desc = keys.desc })
	end
end

---Base keymaps that don't depend on any plugin
function M.vanilla()
	local map = vim.keymap.set
	local cmd = vim.api.nvim_create_user_command

	-- Help / Diagnostics
	map("n", "<leader>?", "<cmd>help <C-r>/<cr>", { desc = "Gets help for the word under the cursor." })
	map("n", "<leader>ck", f.check_keys,        { desc = "[C]heck [K]eys and print info." })
	local vtext = 0
	map("n", '<leader>xv', function()
		-- 0 = disabled
		-- 1 = virtual_text
		-- 2 = virtual_lines
		vtext = (vtext + 1) % 3
		vim.diagnostic.config({
			virtual_text = vtext == 1,
			virtual_lines = vtext == 2,
		})
	end, { desc = 'Toggle diagnostic virtual_text' })

	-- Movements and edits
	map("i", "kj",              "<esc>",                  { desc = "Quick return to normal mode from insert mode." })
	map("v", "KJ",              "<esc>",                  { desc = "Quick return to normal mode from visual mode." })
	map("i", "<C-l>",           f.exit_treesitter_node, { desc = "Exit pair without having to type closing match." })
	map("n", "<leader>b",       ":buffers<cr>:b<space>",  { desc = "Shows buffers and prompt for a choice" })
	map("n", "<leader><space>", "<cmd>noh<cr>",           { desc = "Remove search highlights." })
	map("c", "<C-k>",           "<up>",                   { desc = "Move up on command history." })
	map("c", "<C-j>",           "<down>",                 { desc = "Move down on command history." })
	map("v", "<",               "<gv",                    { desc = "Stay in visual mode after remove indent command." })
	map("v", ">",               ">gv",                    { desc = "Stay in visual mode after add indent command." })
	map("n", "<M-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
	map("n", "<M-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
	map("i", "<M-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
	map("i", "<M-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
	map("v", "<M-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
	map("v", "<M-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

	local pairs = {
		{ left = "'", right = "'" },
		{ left = '"', right = '"' },
		{ left = '(', right = ')' },
		{ left = '[', right = ']' },
		{ left = '{', right = '}' },
		{ left = '<', right = '>' },
	}
	for _, pair in ipairs(pairs) do
		local desc = "Surround selection with " .. pair.left .. " " .. pair.right
		local lhs  = "<leader>" .. pair.left
		local rhs  = ":<C-u>normal!"
		rhs = rhs .. "`>a" .. pair.right .. "<Esc>"
		rhs = rhs .. "`<i" .. pair.left  .. "<Esc>"
		map("v", lhs, rhs, { desc = desc })
	end

	-- TODO:
	-- * replace selection with cut buffer (use treesitter to extract/remove var?)

	-- Toggles
	map("n", "<F2>", f.toggle_inlay_hints,                           { desc = "Toggle inlay hints." })
	map("n", "<F3>", ":set list!<CR>:set list?<CR>",                 { desc = "Toggle invisible chars." })
	map("n", "<F4>", ":set wrap!<CR>:set wrap?<CR>",                 { desc = "Toggle line wrap." })
	map("n", "<F5>", ":set cursorline!<CR>:set cursorline?<CR>",     { desc = "Toggle cursorline." })
	map("n", "<F6>", ":set cursorcolumn!<CR>:set cursorcolumn?<CR>", { desc = "Toggle cursorcolumn." })
	-- TODO: toggle comments visibility with treesitter query (possible?)

	-- Window navigation
	map("n", "<leader>wv", "<cmd>vnew",  { desc = "[W]indow [v]ertical split." })
	map("n", "<leader>wh", "<cmd>new",   { desc = "[W]indow [h]orizontal split." })
	map("n", "<C-h>",      "<C-w><C-h>", { desc = "Move focus to the left window." })
	map("n", "<C-j>",      "<C-w><C-j>", { desc = "Move focus to the bottom window." })
	map("n", "<C-k>",      "<C-w><C-k>", { desc = "Move focus to the top window." })
	map("n", "<C-l>",      "<C-w><C-l>", { desc = "Move focus to the right window." })

	-- Folds
	map("n", "zl", function()
		vim.opt.foldlevel = vim.v.count
	end, { desc = "Set foldlevel to N." })
	map("n", "zI", "zR", { desc = "Expand all folds (because zR is cumbersome)." })

	--
	-- TODO: Review these mappings, which still work and which are unneeded
	--

	-- Bash utilities
	map("n", "<leader>sh", "<cmd>w !bash<cr>",    { desc = "Exec buffer in Bash." })
	map("n", "<leader>sr", "<cmd>% !bash<cr>",    { desc = "Exec buffer in Bash and write output to buffer." })
	map("x", "<leader>sr", "<cmd>  !bash<cr>",    { desc = "Exec buffer in Bash and write output to buffer." })
	map("n", "<leader>uu", "<cmd>r !uuidgen<cr>", { desc = "Generate a new UUID." })

	-- Commands
	cmd("Encode",     "%!base64 | tr -d '\n'", { range = true })
	cmd("Decode",     "%!base64 -d", { range = true })
	cmd("XMLFormat",  "%!XMLLINT_INDENT='  ' xmllint --format -", { range = true })
	cmd("JSONFormat", "%!jq -M '.'", { range = true })
	cmd("JSONSmall",  "%!jq -Mc '.'", { range = true })
end

---Keys for Telescope
---@return LazyKeysSpec
function M.telescope()
	local builtin = require("telescope.builtin")
	local actions = require("telescope.actions")

	local live_grep = function()
		if vim.fn.executable("rg") == 1 then
			builtin.live_grep() -- depends on ripgrep
		else
			vim.notify("Can't call Telescope.live_grep because ripgrep is not in the path.", vim.log.levels.ERROR)
		end
	end

	return {
		-- builtin mappings
		{ "<leader>ff", builtin.find_files,          mode = "n", desc = "[F]ind [F]iles." },
		{ "<leader>fg", live_grep,                   mode = "n", desc = "[F]ind using [G]rep." },
		{ "<leader>fd", builtin.diagnostics,         mode = "n", desc = "[F]ind [D]iagnostics." },
		{ "<leader>fr", builtin.resume,              mode = "n", desc = "[F]inder [R]esume." },
		{ "<leader>f.", builtin.oldfiles,            mode = "n", desc = "[F]ind recent files." },
		{ "<leader>fb", builtin.buffers,             mode = "n", desc = "[F]ind existing [B]uffers." },

		-- code actions
		{ "<leader>cr", builtin.lsp_references,      mode = "n", desc = "[C]ode go to [R]eferences." },
		{ "<leader>ci", builtin.lsp_implementations, mode = "n", desc = "[C]ode go to [I]mplementations." },
	}
end

---Keys for basic LSP actions
---@return LazyKeysSpec
function M.lsp()
	return {
		{ "<leader>ch", vim.lsp.buf.hover,         mode = "n",          desc = "[C]ode [H]over documentation." },
		{ "<leader>cd", vim.lsp.buf.definition,    mode = "n",          desc = "[C]ode go to [D]efinition." },
		{ "<leader>ca", vim.lsp.buf.code_action,   mode = { "n", "v" }, desc = "[C]ode [A]ctions." },
		{ "<leader>cR", vim.lsp.buf.rename,        mode = "n",          desc = "[C]ode [R]ename." },
		{ "<leader>cD", vim.lsp.buf.declaration,   mode = "n",          desc = "[C]ode go to [D]eclaration." },
		{ "<leader>cp", vim.diagnostic.open_float, mode = "n",          desc = "[C]ode show [P]roblem." }
	}
end

---Keys for none-ls (formatter)
---@return LazyKeysSpec
function M.none_ls()
	return {
		{ "<leader>cf", vim.lsp.buf.format, mode = { "n", "v" }, desc = "[C]ode [F]ormat." },
	}
end

---Keys for DAP (debugger)
function M.dap()
	local dap = require("dap")
	local dapui = require("dapui")
	local map = vim.keymap.set

	local eval_under_cursor = function()
		dapui.eval(nil, { enter = true})
	end

	map("n", "<leader>db", dap.toggle_breakpoint, { desc = "[D]ebug: Toggle [b]reakpoint" })
	map("n", "<leader>ds", dap.continue,          { desc = "[D]ebug: [S]tart/Continue" })
	map("n", "<leader>dt", dap.terminate,         { desc = "[D]ebug: [T]erminate" })
	map("n", "<leader>di", dap.step_into,         { desc = "[D]ebug: Step [I]nto" })
	map("n", "<leader>do", dap.step_over,         { desc = "[D]ebug: Step [o]ver" })
	map("n", "<leader>dO", dap.step_out,          { desc = "[D]ebug: Step [O]ut" })
	map("n", "<leader>dC", dap.run_to_cursor,     { desc = "[D]ebug: Run to [C]ursor" })
	map("n", "<leader>d?", eval_under_cursor,     { desc = "[D]ebug: Inspect [?]" })
	map("n", "<leader>dc", dapui.close,           { desc = "[D]ebug: [c]lose UI" })

-- {
--       { '<leader>dB', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = 'Breakpoint Condition' },
--       { '<leader>dg', dap.goto_, desc = 'Go to Line (No Execute)' },
--       { '<leader>dj', dap.down, desc = 'Down' },
--       { '<leader>dk', dap.up, desc = 'Up' },
--       { '<leader>dl', dap.run_last, desc = 'Run Last' },
--       { '<leader>dP', dap.pause, desc = 'Pause' },
--       { '<leader>dr', dap.repl.toggle, desc = 'Toggle REPL' },
--       { '<leader>dt', dap.terminate, desc = 'Terminate' },
--       { '<leader>dw', function() require('dap.ui.widgets').hover() end, desc = 'Widgets' },
--     }
end

---Keys for SpringBoot
---@return LazyKeysSpec
function M.spring_boot()
	local springboot = f.springboot

	return {
		{ "<leader>Jr", springboot.run,                mode = "n", desc = "[J]ava [R]un SpringBoot." },
		{ "<leader>Jc", springboot.generate_class,     mode = "n", desc = "[J]ava Create [C]lass." },
		{ "<leader>Ji", springboot.generate_interface, mode = "n", desc = "[J]ava Create [I]nterface." },
		{ "<leader>Je", springboot.generate_enum,      mode = "n", desc = "[J]ava Create [E]num." },
	}
end

---Keys for Git
---@return LazyKeysSpec
function M.git()
	return {
		{ "<leader>gs", ":Git<cr>",       mode = "n", desc = "[G]it Status." },
		{ "<leader>ga", ":Git add",       mode = "n", desc = "[G]it [A]dd." },
		{ "<leader>gA", ":Git add .<cr>", mode = "n", desc = "[G]it Add [A]ll." },
		{ "<leader>gc", ":Git commit",    mode = "n", desc = "[G]it [C]ommit." },
		{ "<leader>gp", ":Git push",      mode = "n", desc = "[G]it [P]ush." },
		{ "<leader>gb", ":Git blame<cr>", mode = "n", desc = "[G]it [B]lame." },
	}
end

---Keys for Gitsigns
---@return LazyKeysSpec
function M.gitsigns()
	return {
		{ "<leader>gh", ":Gitsigns preview_hunk<cr>", mode = "n",  desc = "[G]it Preview [H]unk." },
	}
end

---Keys for harpoon
---@return LazyKeysSpec
function M.harpoon()
	local harpoon = f.harpoon

	return {
		{ "M",          harpoon.mark,              desc = "[M]ark Harpoon file." },
		{ "U",          harpoon.unmark,            desc = "[U]nmark nth Harpoon file." },
		{ "<leader>H",  harpoon.toggle_quick_menu, desc = "Toggle Harpoon menu." },
		{ "<leader>fh", harpoon.toggle_telescope,  desc = "Navigate through Harpoon marks using Telescope." },
		{ "<leader>j",  harpoon.next_mark,         desc = "Jump to next ↓ Harpoon mark." },
		{ "<leader>k",  harpoon.prev_mark,         desc = "Jump to prev ↑ Harpoon mark." },
		{ "<leader>h",  harpoon.nth_mark,          desc = "Jump to Nth Harpoon mark." },
	}
end

---Keys for Nvim-tree
---@return LazyKeysSpec
function M.nvim_tree()
	return {
		{ "<leader>e", "<cmd>NvimTreeToggle<CR>", mode = "n", desc = "Toggle [E]xplorer" },
		{ "<leader>te", f.nvim_tree_hl,         mode = "n", desc = "Highlight current buffer in NvimTree." },
	}
end

---Autocmd to load vanilla keymaps on initialization
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("keymaps", { clear = true }),
	callback = M.vanilla,
})

local function snip()
	local ls = require("luasnip")
	local s = ls.snippet
	local sn = ls.snippet_node
	local isn = ls.indent_snippet_node
	local t = ls.text_node
	local i = ls.insert_node
	local f = ls.function_node
	local c = ls.choice_node
	local d = ls.dynamic_node
	local r = ls.restore_node

	-- Expand or jump forward in Insert mode
	vim.keymap.set({"i", "s"}, "<Tab>", function()
	  if ls.expand_or_jumpable() then
		 ls.expand_or_jump()
	  else
		 -- Fallback: if not in a snippet, insert a regular tab
		 -- You can remove this or change to another behavior
		 vim.api.nvim_feedkeys(vim.api.nvim_replace_keycodes("<Tab>"), "n", false)
	  end
	end, { silent = true })

	-- Jump backward in Insert and Select mode
	vim.keymap.set({"i", "s"}, "<S-Tab>", function()
	  if ls.jumpable(-1) then
		 ls.jump(-1)
	  end
	end, { silent = true })

	ls.add_snippets("all", {
		s("trig", {
			i(1, "ABC"), t(":text:"), i(2), t(":text again:"), i(3),
		})
	})
end

return M
