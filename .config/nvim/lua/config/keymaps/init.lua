vim.g.mapleader = "ç"
vim.g.maplocalleader = "ç"

local M = {}

local f = require("config.keymaps.functions")
local map = vim.keymap.set
local cmd = vim.api.nvim_create_user_command

---Base keymaps that don't depend on any plugin
function M.vanilla()

	map("n", "<leader>C", f.rotate_colorscheme, { desc = "Rotate colorschemes." })
	map("n", "<leader>r", "<cmd>restart<cr>",   { desc = "Restart." })

	-- Help / Diagnostics
	map("n", "<leader>ck", f.check_keys,                       { desc = "Check keys and print maps, if any." })
	map("n", "<leader>xv", f.get_fn_toggle_diagnostics_virt(), { desc = 'Toggle diagnostic virtual_text', expr = true })

	-- Movements and edits
	map("i", "kj",              "<esc>",                  { desc = "Return to normal mode from insert mode." })
	map("t", "kj",              "<C-\\><C-n>",            { desc = "Return to normal mode from terminal mode." })
	map("v", "KJ",              "<esc>",                  { desc = "Quick return to normal mode from visual mode." })
	map("i", "<C-l>",           f.exit_treesitter_node,   { desc = "Exit pair without having to type closing match." })
	map("n", "<leader>b",       ":buffers<cr>:b<space>",  { desc = "Shows buffers and prompt for a choice" })
	map("n", "<leader><space>", "<cmd>noh<cr>",           { desc = "Remove search highlights." })
	map("c", "<C-k>",           "<up>",                   { desc = "Move up on command history." })
	map("c", "<C-j>",           "<down>",                 { desc = "Move down on command history." })
	map("v", "<",               "<gv",                    { desc = "Stay in visual mode after remove indent command." })
	map("v", ">",               ">gv",                    { desc = "Stay in visual mode after add indent command." })

	-- Alt+j and Alt+k for moving lines around
	map("i", "<M-k>", "<esc><cmd>m .-2<cr>==gi",                               { desc = "Move current line up in insert mode." })
	map("i", "<M-j>", "<esc><cmd>m .+1<cr>==gi",                               { desc = "Move current line down in insert mode." })
	map("n", "<M-k>", "<cmd>exe 'move .-' . (v:count1 + 1)<cr>==",             { desc = "Move current line up in normal mode." })
	map("n", "<M-j>", "<cmd>exe 'move .+' . v:count1<cr>==",                   { desc = "Move current line down in normal mode." })
	map("v", "<M-k>", ":<C-u>exe \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move selected lines up in visual mode." })
	map("v", "<M-j>", ":<C-u>exe \"'<,'>move '>+\" . v:count1<cr>gv=gv",       { desc = "Move selected lines down in visual mode." })

	-- Surrounding selected text with a given pair of (), "", {} etc.
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
		local rhs  = "<cmd><C-u>normal!"
		rhs = rhs .. "`>a" .. pair.right .. "<esc>"
		rhs = rhs .. "`<i" .. pair.left  .. "<esc>"
		map("v", lhs, rhs, { desc = desc })
	end

	-- TODO:
	-- * replace selection with cut buffer (use treesitter to extract/remove var?)

	-- Toggles
	map("n", "<F2>", f.toggle_inlay_hints,                                   { desc = "Toggle inlay hints." })
	map("n", "<F3>", "<cmd>set list!<CR><cmd>set list?<CR>",                 { desc = "Toggle invisible chars." })
	map("n", "<F4>", "<cmd>set wrap!<CR><cmd>set wrap?<CR>",                 { desc = "Toggle line wrap." })
	map("n", "<F5>", "<cmd>set cursorline!<CR><cmd>set cursorline?<CR>",     { desc = "Toggle cursorline." })
	map("n", "<F6>", "<cmd>set cursorcolumn!<CR><cmd>set cursorcolumn?<CR>", { desc = "Toggle cursorcolumn." })
	-- TODO: toggle comments visibility with treesitter query (possible?)

	-- Window navigation
	map("n", "<leader>wv", "<cmd>vnew",  { desc = "Window vertical split." })
	map("n", "<leader>wh", "<cmd>new",   { desc = "Window horizontal split." })
	map("n", "<C-h>",      "<C-w><C-h>", { desc = "Move focus to the left window." })
	map("n", "<C-j>",      "<C-w><C-j>", { desc = "Move focus to the bottom window." })
	map("n", "<C-k>",      "<C-w><C-k>", { desc = "Move focus to the top window." })
	map("n", "<C-l>",      "<C-w><C-l>", { desc = "Move focus to the right window." })

	-- Folds
	map("n", "zl", function() vim.opt.foldlevel = vim.v.count end, { desc = "Set foldlevel to N." })
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
function M.telescope()
	local builtin = require("telescope.builtin")

	local live_grep = function()
		if vim.fn.executable("rg") == 1 then
			builtin.live_grep() -- depends on ripgrep
		else
			vim.notify("Can't call Telescope.live_grep because ripgrep is not in the path.", vim.log.levels.ERROR)
		end
	end

	-- builtin mappings
	map("n", "<leader>ff", builtin.find_files,          { desc = "Find Files." })
	map("n", "<leader>fg", live_grep,                   { desc = "Find using Grep." })
	map("n", "<leader>fd", builtin.diagnostics,         { desc = "Find Diagnostics." })
	map("n", "<leader>fr", builtin.resume,              { desc = "Finder Resume." })
	map("n", "<leader>f.", builtin.oldfiles,            { desc = "Find recent files." })
	map("n", "<leader>fb", builtin.buffers,             { desc = "Find existing Buffers." })

	-- code actions
	map("n", "<leader>cr", builtin.lsp_references,      { desc = "Code go to References." })
	map("n", "<leader>ci", builtin.lsp_implementations, { desc = "Code go to Implementations." })
end

---Keys for basic LSP actions
function M.lsp()
	map("n",          "<leader>ch", vim.lsp.buf.hover,         { desc = "Code Hover documentation." })
	map("n",          "<leader>cd", vim.lsp.buf.definition,    { desc = "Code go to Definition." })
	map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action,   { desc = "Code Actions." })
	map("n",          "<leader>cR", vim.lsp.buf.rename,        { desc = "Code Rename." })
	map("n",          "<leader>cD", vim.lsp.buf.declaration,   { desc = "Code go to Declaration." })
	map("n",          "<leader>cp", vim.diagnostic.open_float, { desc = "Code show Problem." })
end

---Keys for none-ls (formatter)
function M.none_ls()
	map({ "n", "v" }, "<leader>cf", vim.lsp.buf.format, { desc = "Code Format." })
end

---Keys for DAP (debugger)
function M.dap()
	local dap = require("dap")
	local dapui = require("dapui")

	local eval_under_cursor = function()
		dapui.eval(nil, { enter = true})
	end

	map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
	map("n", "<leader>ds", dap.continue,          { desc = "Debug: Start/Continue" })
	map("n", "<leader>dt", dap.terminate,         { desc = "Debug: Terminate" })
	map("n", "<leader>di", dap.step_into,         { desc = "Debug: Step Into" })
	map("n", "<leader>do", dap.step_over,         { desc = "Debug: Step over" })
	map("n", "<leader>dO", dap.step_out,          { desc = "Debug: Step Out" })
	map("n", "<leader>dC", dap.run_to_cursor,     { desc = "Debug: Run to Cursor" })
	map("n", "<leader>d?", eval_under_cursor,     { desc = "Debug: Inspect ?" })
	map("n", "<leader>dc", dapui.close,           { desc = "Debug: close UI" })

	-- map("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Breakpoint Condition" })
	-- map("n", "<leader>dg", dap.goto_,       { desc = "Go to Line (No Execute)" })
	-- map("n", "<leader>dj", dap.down,        { desc = "Down" })
	-- map("n", "<leader>dk", dap.up,          { desc = "Up" })
	-- map("n", "<leader>dl", dap.run_last,    { desc = "Run Last" })
	-- map("n", "<leader>dP", dap.pause,       { desc = "Pause" })
	-- map("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
	-- map("n", "<leader>dt", dap.terminate,   { desc = "Terminate" })
	-- map("n", "<leader>dw", function() require('dap.ui.widgets').hover() end, { desc = "Widgets" })
end

---Keys for SpringBoot
function M.springboot()
	local springboot = f.springboot

	map("n", "<leader>Jr", springboot.run,                { desc = "Run SpringBoot." })
	map("n", "<leader>Jc", springboot.generate_class,     { desc = "Create Java Class." })
	map("n", "<leader>Ji", springboot.generate_interface, { desc = "Create Java Interface." })
	map("n", "<leader>Je", springboot.generate_enum,      { desc = "Create Java Enum." })
end

---Keys for Git
function M.git()
	map("n", "<leader>gs", ":Git<cr>",       { desc = "Git Status." })
	map("n", "<leader>ga", ":Git add",       { desc = "Git Add." })
	map("n", "<leader>gA", ":Git add .<cr>", { desc = "Git Add All." })
	map("n", "<leader>gc", ":Git commit",    { desc = "Git Commit." })
	map("n", "<leader>gp", ":Git push",      { desc = "Git Push." })
	map("n", "<leader>gb", ":Git blame<cr>", { desc = "Git Blame." })
end

---Keys for Gitsigns
function M.gitsigns()
	map("n", "<leader>gh", ":Gitsigns preview_hunk<cr>", { desc = "Git Preview Hunk." })
end

---Keys for harpoon
function M.harpoon()
	local harpoon = f.harpoon

	map("n", "M",          harpoon.mark,              { desc = "Mark Harpoon file." })
	map("n", "U",          harpoon.unmark,            { desc = "Unmark nth Harpoon file." })
	map("n", "<leader>H",  harpoon.toggle_quick_menu, { desc = "Toggle Harpoon menu." })
	map("n", "<leader>fh", harpoon.toggle_telescope,  { desc = "Navigate through Harpoon marks using Telescope." })
	map("n", "<leader>j",  harpoon.next_mark,         { desc = "Jump to next ↓ Harpoon mark." })
	map("n", "<leader>k",  harpoon.prev_mark,         { desc = "Jump to prev ↑ Harpoon mark." })
	map("n", "<leader>h",  harpoon.nth_mark,          { desc = "Jump to Nth Harpoon mark." })
end

---Keys for Nvim-tree
function M.nvim_tree()
	map("n", "<leader>e",  "<cmd>NvimTreeToggle<CR>", { desc = "Toggle Explorer" })
	map("n", "<leader>te", f.nvim_tree_hl,            { desc = "Highlight current buffer in NvimTree." })
end

---Autocmd to load vanilla keymaps on initialization
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("keymaps", { clear = true }),
	callback = M.vanilla,
})

return M
