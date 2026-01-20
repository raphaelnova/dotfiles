local M = {}

local function find_project_root()
	local root_markers = { "pom.xml", "build.gradle", "settings.gradle", ".git" }
	local path = vim.fs.find(root_markers, { upward = true })[1]
	return path and vim.fs.dirname(path) or nil
end

local function find_root_package(src_root)
	local pkg = {}
	local current = src_root

	while true do
		local entries = vim.fn.readdir(current)
		local dirs, files = {}, {}

		for _, e in ipairs(entries) do
			local p = current .. "/" .. e
			if vim.fn.isdirectory(p) == 1 then
				table.insert(dirs, e)
			elseif e:match("%.java$") then
				table.insert(files, e)
			end
		end

		if #files > 0 then
			break
		end
		if #dirs ~= 1 then
			break
		end

		table.insert(pkg, dirs[1])
		current = current .. "/" .. dirs[1]
	end

	return table.concat(pkg, "."), current
end

local function scan_packages(base_dir, base_pkg, pkgs)
	pkgs = pkgs or {}
	local entries = vim.fn.readdir(base_dir)

	for _, e in ipairs(entries) do
		local p = base_dir .. "/" .. e
		if vim.fn.isdirectory(p) == 1 then
			local pkg = base_pkg ~= "" and (base_pkg .. "." .. e) or e
			table.insert(pkgs, pkg)
			scan_packages(p, pkg, pkgs)
		end
	end

	return pkgs
end

local function class_template(kind, pkg, name)
	local lines = {}

	if pkg ~= "" then
		table.insert(lines, "package " .. pkg .. ";")
		table.insert(lines, "")
	end

	if kind == "Class" then
		table.insert(lines, "public class " .. name .. " {")
		table.insert(lines, "")
		table.insert(lines, "}")
	elseif kind == "Enum" then
		table.insert(lines, "public enum " .. name .. " {")
		table.insert(lines, "")
		table.insert(lines, "}")
	elseif kind == "Interface" then
		table.insert(lines, "public interface " .. name .. " {")
		table.insert(lines, "")
		table.insert(lines, "}")
	elseif kind == "Record" then
		table.insert(lines, "public record " .. name .. "() {")
		table.insert(lines, "")
		table.insert(lines, "}")
	elseif kind == "Annotation" then
		table.insert(lines, "public @interface " .. name .. " {")
		table.insert(lines, "")
		table.insert(lines, "}")
	end

	return lines
end

function _G.java_package_complete(arg_lead, cmd_line, cursor_pos)
	local root_pkg = _G.__java_root_pkg
	local root_dir = _G.__java_root_dir

	local all = scan_packages(root_dir, root_pkg)
	local out = {}

	for _, p in ipairs(all) do
		if p:find("^" .. vim.pesc(arg_lead)) then
			table.insert(out, p)
		end
	end

	return out
end

local function input(opts)
	local co = assert(coroutine.running(), "No coroutine here! We're in the main thread!")
	vim.schedule(function()
		vim.ui.input(opts or {}, function(value)
			coroutine.resume(co, value)
		end)
	end)
	return coroutine.yield()
end

local function select(choices, opts)
	local co = assert(coroutine.running(), "No coroutine here! We're in the main thread!")
	vim.schedule(function()
		vim.ui.select(choices or {}, opts or {}, function(value)
			coroutine.resume(co, value)
		end)
	end)
	return coroutine.yield()
end

function M.new_type_element()
	local root = find_project_root()
	if not root then
		vim.notify("Java project root not found", vim.log.levels.ERROR)
		return
	end

	local src_root = root .. "/src/main/java"
	if not vim.fn.isdirectory(src_root) == 1 then
		vim.notify("src/main/java not found", vim.log.levels.ERROR)
		return
	end

	local root_pkg, root_dir = find_root_package(src_root)
	_G.__java_root_pkg = root_pkg
	_G.__java_root_dir = root_dir

	local ts_name = ""
	local ts_kind = ""
	-- If node under the cursor is a type, use it to prefill the input
	local ok, node = pcall(vim.treesitter.get_node)
	if ok and node then
		if node:type() == "type_identifier" then
			ts_name = vim.treesitter.get_node_text(node, 0)
		elseif node:type() == "identifier" and node:parent():type() == "marker_annotation" then
			ts_name = vim.treesitter.get_node_text(node, 0)
			ts_kind = "Annotation"
		end
	end

	coroutine.wrap(function()
		local pkg = input({
			prompt = "Package: ",
			default = root_pkg,
			completion = "customlist,v:lua.java_package_complete",
		})
		if not pkg or pkg == "" then return end

		local name = input({
			prompt = "Type Element name: ",
			default = ts_name,
		})
		if not name or name == "" then return end

		local kind = ""
		if name == ts_name and ts_kind ~= "" then
			-- Creating the type element under the cursor (an annotation)
			-- only if the user chose the same name
			kind = ts_kind
		else
			kind = select({
				"Class",
				"Enum",
				"Interface",
				"Record",
				"Annotation"
			}, { prompt = "Type: " })
		end
		if not kind then return end

		local dir = src_root .. "/" .. pkg:gsub("%.", "/")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end

		local path = dir .. "/" .. name .. ".java"
		if vim.fn.filereadable(path) == 1 then
			vim.notify("File already exists: " .. path, vim.log.levels.ERROR)
			return
		end

		local content = class_template(kind, pkg, name)
		vim.fn.writefile(content, path)

		vim.cmd.edit(path)

		-- TODO: Expand snippet after opening instead of writing class_template to it.
	end)()
end

return M
