local M = {}

local _mason_refresh = {
	done = false,
	in_progress = false,
	callback_queue = {},
}

--- Use a module if it exists. Fail silently if it doesn't.
--- @param module_name string The module to require
--- @param callback function A callback that receives and uses the module.
function M.try_with(module_name, callback)
	local ok, module = pcall(require, module_name)
	if ok then
		callback(module)
	end
end

--- Installs a Tree-sitter parser.
--- @param parser string The parser to install
function M.ts_install(parser)
	local parsers = require("nvim-treesitter.parsers")
	local configs = parsers.get_parser_configs()

	if configs[parser] and not parsers.has_parser(parser) then
		vim.schedule(function()
			vim.cmd("TSInstall " .. parser)
			print("Installing treesitter parser '" .. parser .. "'...")
		end)
	end
end


--- Installs a Mason package and calls the `callback` when it succeeds or fails.
--- @param mason_pkg string The name of the package to install.
--- @param callback? function An optional callback function with param `success: boolean`
function M.mason_install(mason_pkg, callback)
	callback = callback or function() end

	local registry = require("mason-registry")

	-- Check whether the package exists in the registry and whether it's been
	-- isntalled or is being installed. Calls :install and registers the callback
	local install = function(_mason_pkg, _callback)
		if registry.has_package(_mason_pkg) then
			local pkg = registry.get_package(_mason_pkg)
			if not pkg:is_installed() and not pkg:is_installing() then
				pkg:install({}, function(success, results)
					if success then
						print("Installed '" .. results.name .. "' successfully.")
					else
						print("Failed to install '" .. results.name .. "'.")
					end
					_callback(success)
				end)
			end
		else
			vim.notify(
				debug.traceback("Package '" .. _mason_pkg .. "' does not exist."),
				vim.log.levels.ERROR)
		end
	end

	-- Check whether the registry has been refreshed before installing tools.
	-- If it hasn't, refresh it and queue any callbacks until it's done. Runs
	-- all callbacks after refreshing.
	if _mason_refresh.done then
		install(mason_pkg, callback)
	elseif _mason_refresh.in_progress then
		table.insert(_mason_refresh.callback_queue, function()
			install(mason_pkg, callback)
		end)
	else
		print("Refreshing Mason registry...")
		_mason_refresh.in_progress = true
		registry.refresh(function()
			for _, _callback in ipairs(_mason_refresh.callback_queue) do
				_callback()
			end
			_mason_refresh.in_progress = false
			_mason_refresh.done = true
			install(mason_pkg, callback)
		end)
	end
end

return M
