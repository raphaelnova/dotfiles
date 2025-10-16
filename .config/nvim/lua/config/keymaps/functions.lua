local M = {}

---Read a sequence of keys and a mode and check if there are mappings tied to these inputs.
function M.check_keys()
	local keys = vim.fn.input("Check keys: ")
	if keys == "" then
		return
	end

	local all_modes = { "n", "i", "c", "v", "s", "x", "o", "l", "t" }
	local input_modes = vim.fn.input("Modes (nicvsxolt): ")
	local maps_by_mode = {}

	if input_modes ~= "" then
		-- Iterate over input modes, check against valid modes and get keymaps
		for mode in input_modes:gmatch(".") do
			for _, listed_mode in pairs(all_modes) do
				if string.lower(mode) == listed_mode then
					local keymap = vim.fn.maparg(keys, listed_mode, false, true)
					if next(keymap) then
						maps_by_mode[listed_mode] = keymap
					end
				end
			end -- loop all_modes
		end -- loop input_mode
	else
		-- Check all modes for keymaps
		for _, listed_mode in ipairs(all_modes) do
			local keymap = vim.fn.maparg(keys, listed_mode, false, true)
			if next(keymap) then
				maps_by_mode[listed_mode] = keymap
			end
		end
	end

	if next(maps_by_mode) then
		print(vim.inspect(maps_by_mode))
	else
		vim.notify("No maps found for key sequence: " .. keys, vim.log.levels.INFO)
	end
end

---Enable/disable LSP inlay hints
function M.toggle_inlay_hints()
	local hint_switch = not vim.lsp.inlay_hint.is_enabled()
	vim.lsp.inlay_hint.enable(hint_switch)
	if hint_switch then
		print("  hints")
	else
		print("nohints")
	end
end

---Get out of pairs in insert mode without having to type the closing match
function M.exit_treesitter_node()
	local node = vim.treesitter.get_node()
	if node ~= nil then
		local row, col = node:end_()
		pcall(vim.api.nvim_win_set_cursor, 0, { row + 1, col })
	end
end

---Highlights the current buffer in NvimTree
function M.nvim_tree_hl()
	require("nvim-tree.api").tree.find_file({ buf = vim.fn.bufnr() })
end

--
-- Harpoon namespace
--
M.harpoon = {}

---Creates a harpoon picker with Telescope
local function _toggle_telescope(harpoon_files)
	local file_paths = {}
	for _, item in ipairs(harpoon_files.items) do
		table.insert(file_paths, item.value)
	end

	local conf = require("telescope.config").values
	require("telescope.pickers").new({}, {
		prompt_title = "Harpoon",
		finder = require("telescope.finders").new_table({
			results = file_paths,
		}),
		previewer = conf.file_previewer({}),
		sorter = conf.generic_sorter({}),
	}):find()
end

---Opens a quick menu with harpoon marks
function M.harpoon.toggle_quick_menu()
	local harpoon = require("harpoon")
	harpoon.ui:toggle_quick_menu(harpoon:list())
end

---Opens a Telescope menu with harpoon marks
function M.harpoon.toggle_telescope()
	_toggle_telescope(require("harpoon"):list())
end

---Mark file with harpoon
function M.harpoon.mark()
	require("harpoon"):list():add()
end

---Remove file from marks
function M.harpoon.unmark()
	local harpoon = require("harpoon")
	if vim.v.count == 0 then
		-- "U" removes the current harpoon entry
		harpoon:list():remove()
	else
		-- "3U" removes the 3rd harpoon entry
		harpoon:list():remove_at(vim.v.count)
	end
end

---Jumps to next mark
function M.harpoon.next_mark()
	require("harpoon"):list():next({ ui_nav_wrap = true })
end

---Jumps to previous mark
function M.harpoon.prev_mark()
	require("harpoon"):list():prev({ ui_nav_wrap = true })
end

function M.harpoon.nth_mark()
	local nth = vim.v.count
	local harpoon = require("harpoon")
	vim.schedule(function()
		-- nvim won't let me change the buffer during a keymap function
		-- giving "E565: Not allowed to change text or change window"
		-- so I need to schedule the change so it happens after this
		-- keymap execution
		if nth == 0 then
			harpoon:list():next({ ui_nav_wrap = true })
		else
			harpoon:list():select(nth)
		end
		-- It's weird that defer_fn takes a timeout param and schedule
		-- does not, should be the other way. When you schedule you choose
		-- the timing, when you defer you don't
	end)
end

--
-- Spring Boot namespace
--
M.springboot = {}

---Starts a SpringBoot app
function M.springboot.run()
	require("springboot-nvim").boot_run()
end

---Generates a new Java class
function M.springboot.generate_class()
	require("springboot-nvim").generate_class()
end

---Generates a new Java interface
function M.springboot.generate_interface()
	require("springboot-nvim").generate_interface()
end

---Generates a new Java enum
function M.springboot.generate_enum()
	require("springboot-nvim").generate_enum()
end

return M
