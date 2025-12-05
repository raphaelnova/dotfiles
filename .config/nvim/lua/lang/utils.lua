local M = {}

function M.try_with(module_name, callback)
	local ok, module = pcall(require, module_name)
	if ok then
		callback(module)
	end
end

function M.ts_install(language)
	local parsers = require("nvim-treesitter.parsers")
	local configs = parsers.get_parser_configs()

	if configs[language] and not parsers.has_parser(language) then
		vim.schedule_wrap(function()
			vim.cmd("TSInstall " .. language)
			vim.notify("Installing treesitter parser for '" .. language .. "'...", vim.log.levels.INFO)
		end)()
	end
end

--- Installs null-ls binary sources with mason, if they are missing.
--- @param sources string|string[] One or more sources to install.
function M.null_install(sources)
	if type(sources) == "string" then
		sources = { sources }
	end

	local currently_installed = {}
	for _, source in ipairs(require("mason-null-ls").get_installed_sources()) do
		currently_installed[source] = true
	end

	local missing = {}

	for _, source in ipairs(sources) do
		if not currently_installed[source] then
			table.insert(missing, source)
		end
	end

	if #missing > 0 then
		local missing_str = table.concat(missing, " ")
		vim.notify("Installing missing null-ls sources: " .. missing_str, vim.log.levels.INFO)
		vim.cmd("NullLsInstall " .. missing_str)
	end
end

local function _mason_install_then(packages, callback)
	if type(packages) == "string" then
		packages = { packages }
	end

	local to_install = {}
	local installed = {}
	local non_existent = {}
	local failed = {}

	local registry = require("mason-registry")

	-- Check each candidate's status so we have a count and can notify of
	-- any failures later
	for _, package in ipairs(packages) do
		if not registry.has_package(package) then
			table.insert(non_existent, package)
		elseif not registry.is_installed(package) then
			table.insert(to_install, package)
		end
	end

	local pending = #to_install

	-- Update the count, check whether they were all processed and
	-- fire notifications and callback if true
	local trigger_callback = function()
		if pending == 0 then
			if #installed > 0 then
				print(
					"Mason packages installed: " .. table.concat(installed, ", "),
					vim.log.levels.INFO)
			end
			if #non_existent > 0 then
				print(
					"These packages don't exist in Mason's registry: " .. table.concat(non_existent, ", "),
					vim.log.levels.ERROR)
			end
			if #failed  > 0 then
				print(
					"These packages failed to install: " .. table.concat(failed, ", "),
					vim.log.levels.ERROR)
			end
			callback()
		end
	end

	-- Install packages and register processing events
	print("Installing Mason packages: " .. table.concat(to_install, ", "))
	for _, package in ipairs(to_install) do
		local pkg = registry.get_package(package)
		pkg:on("install:success", function()
			print("Called 'install:success' for " .. pkg:get_name())
		end)
		pkg:on("install:failure", function()
			print("Called 'install:failure' for " .. pkg:get_name())
		end)
		pkg:install({}, function(success, results)
			pending = pending - 1
			if success then
				print("Installed '" .. results.name .. "' successfully.")
				table.insert(installed, results.name)
			else
				print("Failed to install '" .. results.name .. "'.")
				table.insert(failed, results.name)
			end
			trigger_callback()
		end)
	end

	-- In case no work's been done this will trigger immediately
	trigger_callback()
end

--- Installs Mason packages and triggers a callback after processing them all.
--- @param packages string|string[] One or more packages to install.
--- @param callback function A callback function to execute after all packages are installed
function M.mason_install_then(packages, callback)
	M.mason_install_then = _mason_install_then

	require("mason-registry").refresh(function()
		_mason_install_then(packages, callback)
	end)
end

--- An alias to M.mason_install_then with no callback
function M.mason_install(packages)
	M.mason_install_then(packages, function() end)
end

return M
