local M = {}

local markers = { "pom.xml", "build.gradle", "build.gradle.kts", "gradlew", "mvnw" }

--- Returns true if `dir` contains a Java project marker.
--- @param dir string|nil defaults to cwd
function M.detect(dir)
	dir = dir or vim.fn.getcwd()
	for _, m in ipairs(markers) do
		if vim.fn.filereadable(dir .. "/" .. m) == 1 then
			return true
		end
	end
	return false
end

--- Runs `xmllint --xpath` on `file`, returns trimmed output or `nil`.
--- @param file string A path to an XML file
--- @param xpath string The xpath to evaluate
--- @return string|nil
local function xp(file, xpath)
	local safe_xpath = vim.fn.shellescape(xpath)
	local safe_file = vim.fn.shellescape(file)
	local out = vim.fn.system(
		string.format("xmllint --xpath %s %s 2>/dev/null", safe_xpath, safe_file)
	)
	local result = vim.trim(out)
	return result ~= "" and result or nil
end

--- Parses pom.xml in `dir`.
--- Returns a table with `group_id`, `artifact_id` and `java_version`, or `nil`
--- if no pom.xml.
--- @param dir string|nil defaults to cwd
--- @return table|nil
function M.parse_pom(dir)
	dir = dir or vim.fn.getcwd()
	local pom = dir .. "/pom.xml"
	if vim.fn.filereadable(pom) == 0 then
		return nil
	end

	-- groupId: project's own first; fall back to parent's when it's inherited.
	local group_id =
		xp(pom, "/*[local-name()='project']/*[local-name()='groupId']/text()")
		or xp(pom, "/*[local-name()='project']/*[local-name()='parent']/*[local-name()='groupId']/text()")

	local artifact_id =
		xp(pom, "/*[local-name()='project']/*[local-name()='artifactId']/text()")

	-- Java version: try common property names in order of precedence.
	local java_version =
		xp(pom, "/*[local-name()='project']/*[local-name()='properties']/*[local-name()='maven.compiler.release']/text()")
		or xp(pom, "/*[local-name()='project']/*[local-name()='properties']/*[local-name()='maven.compiler.source']/text()")
		or xp(pom, "/*[local-name()='project']/*[local-name()='properties']/*[local-name()='java.version']/text()")

	return {
		group_id = group_id,
		artifact_id = artifact_id,
		java_version = java_version,
	}
end

--- Walks `src_root` downward through single-directory chains until it reaches a
--- directory that contains Java files or branches into multiple subdirectories.
--- That deepest single-chain prefix is the root package common to all classes.
--- Returns (root_package_string, root_package_dir).
--- @param src_root string absolute path to src/main/java
--- @return string, string
function M.find_root_package(src_root)
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

		if #files > 0 or #dirs ~= 1 then break end

		table.insert(pkg, dirs[1])
		current = current .. "/" .. dirs[1]
	end

	return table.concat(pkg, "."), current
end

--- Returns the cached project info stored by the VimEnter autocmd, or nil.
function M.info()
	return vim.g.java_project
end

return M
