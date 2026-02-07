local function get_launcher()
	local jdtls_path = vim.fn.expand("$MASON/packages/jdtls")

	local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
	local config = jdtls_path .. "/config_linux"
	local lombok = jdtls_path .. "/lombok.jar"

	return launcher, config, lombok
end

local function get_bundles()
	local debug_jars = vim.split(
		vim.fn.glob(
			vim.fn.expand("$MASON/packages/java-debug-adapter")
			.. "/extension/server/com.microsoft.java.debug.plugin-*.jar"
		),
		"\n"
	)

	local test_jars = vim.split(
		vim.fn.glob(
			vim.fn.expand("$MASON/packages/java-test")
			.. "/extension/server/*.jar"
		),
		"\n"
	)

	local bundles = {}
	vim.list_extend(bundles, debug_jars)
	vim.list_extend(bundles, test_jars)
	vim.list_extend(bundles, require("spring_boot").java_extensions())

	return bundles
end

local function get_workspace()
	local workspace_path = os.getenv("HOME") .. "/.local/share/eclipse-workspace/"
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

	return workspace_path .. project_name
end

local function java_keymaps()
	local jdtls = require("jdtls")

	vim.api.nvim_buf_create_user_command(0, "JdtUpdateConfig", jdtls.update_project_config, {})
	vim.api.nvim_buf_create_user_command(0, "JdtBytecode", jdtls.javap, {})
	vim.api.nvim_buf_create_user_command(0, "JdtShell", jdtls.jshell, {})
	vim.api.nvim_buf_create_user_command(0, "JdtCompile", function(opts)
		jdtls.compile(opts.args)
	end, {
		nargs = "?",
		complete = function(_, _, _)
			return require("jdtls")._complete_compile()
		end,
	})

	vim.keymap.set(
		"n",
		"<leader>Jn",
		"<cmd>lua require('lang.java.type_element').new_type_element()<CR>",
		{ desc = "[J]ava [N]ew type element." }
	)
	vim.keymap.set(
		"n",
		"<leader>Jo",
		"<cmd>lua require('jdtls').organize_imports()<CR>",
		{ desc = "[J]ava [O]rganize imports." }
	)
	vim.keymap.set(
		"n",
		"<leader>Jv",
		"<cmd>lua require('jdtls').extract_variable()<CR>",
		{ desc = "[J]ava extract [V]ariable." }
	)
	vim.keymap.set(
		"v",
		"<leader>Jv",
		"<esc><cmd>lua require('jdtls').extract_variable(true)<CR>",
		{ desc = "[J]ava extract [V]ariable." }
	)
	vim.keymap.set(
		"n",
		"<leader>JC",
		"<cmd>lua require('jdtls').extract_constant()<CR>",
		{ desc = "[J]ava extract [C]onstant." }
	)
	vim.keymap.set(
		"v",
		"<leader>JC",
		"<esc><cmd>lua require('jdtls').extract_constant(true)<CR>",
		{ desc = "[J]ava extract [C]onstant." }
	)
	vim.keymap.set(
		"n",
		"<leader>Jt",
		"<cmd>lua require('jdtls').test_nearest_method()<CR>",
		{ desc = "[J]ava [T]est method." }
	)
	vim.keymap.set(
		"v",
		"<leader>Jt",
		"<esc><cmd>lua require('jdtls').test_nearest_method(true)<CR>",
		{ desc = "[J]ava [T]est method." }
	)
	vim.keymap.set("n", "<leader>JT", "<cmd>lua require('jdtls').test_class()<CR>", { desc = "[J]ava [T]est class." })
	vim.keymap.set("n", "<leader>Ju", "<cmd>JdtUpdateConfig<CR>", { desc = "[J]ava [U]update config." })
end

local function get_setup_config()
	local launcher, os_config, lombok = get_launcher()
	local bundles = get_bundles()
	local workspace_dir = get_workspace()
	local root_dir = vim.fs.root(0, { ".git", "pom.xml", "mvnw", "gradlew", "build.gradle" })

	local capabilities = vim.tbl_deep_extend("force", require("cmp_nvim_lsp").default_capabilities(), {
		workspace = {
			configuration = true,
		},
		textDocument = {
			completion = {
				snippetSupport = false,
			},
		},
	})

	local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
	extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

	local cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xms128m",
		"-Xmx1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"-javaagent:" .. lombok,
		"-jar", launcher,
		"-configuration", os_config,
		"-data", workspace_dir,
	}

	local settings = {
		java = {
			format = {
				enabled = false,
				-- settings = {
				-- 	url = vim.fn.stdpath("config") .. "/eclipse-java-google-style.xml",
				-- 	profile = "GoogleStyle",
				-- },
			},
			eclipse = {
				downloadSource = true,
				-- exclude = { "target/**" },
			},
			maven = {
				downloadSources = true,
			},
			signatureHelp = {
				enabled = true,
			},
			contentProvider = {
				-- Use fernflower decompiler
				preferred = "fernflower",
			},
			autobuild = {
				enabled = true,
			},
			project = {
				sourcePaths = {
					"src/",
				},
			},
			problems = {
				filters = {
					{
						resource = "target/.*", -- regex relative to project root
						kind = "warning",       -- or "info" or "error"
					},
				},
			},
			jdt = {
				ls = {
					protobuffSupport = {
						enabled = true,
					},
				},
			},
			saveActions = {
				organizeImports = true,
			},
			diagnostics = {
				filter = {
					"target/",
				},
			},
			completion = {
				favoriteStaticMembers = {
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.junit.jupiter.api.Assertions.*",
					"org.mockito.Mockito.*",
				},
				filteredTypes = {
					"com.sun.*",
					"io.micrometer.shaded.*",
					"java.awt.*", -- not this List interface, the other
					"jdk.*",
					"sun.*",
				},
				importOrder = {
					"java",
					"jakarta",
					"javax",
					"com",
					"org",
				},
			},
			sources = {
				organizeImports = {
					starThreshold = 9999,
					staticThreshold = 9999,
				},
			},
			codeGeneration = {
				toString = {
					template = "${object.className}-{${member.name()}=${member.value}, ${otherMembers}}",
				},
				hashCodeEquals = {
					useJava7Objects = true,
				},
				useBlocks = true,
			},
			configuration = {
				updateBuildConfiguration = "interactive",
				-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
				-- runtimes = { -- interface RuntimeOption
				--   {
				--     -- The `name` is NOT arbitrary, check the enum in the link above
				--     name = "JavaSE 11", -- enum ExecutionEnvironment
				--     path = "/usr/lib/jvm/java-11-openjdk/",
				--     -- javadoc?: string
				--     -- sources?: string
				--     -- default?: boolean
				--   },
				-- },
			},
			implementationCodeLens = "all",
			referencesCodeLens = {
				enabled = true,
			},
			inlayHints = {
				parameterNames = {
					enabled = "all",
				},
			},
		},
	}

	local init_options = {
		bundles = bundles,
		extendedClientCapabilities = extendedClientCapabilities,
	}

	local on_attach = function(_, _)
		java_keymaps()

		local dap = require("jdtls.dap")
		dap.setup_dap()                    -- java debug adapter
		dap.setup_dap_main_class_configs() -- find the main method. Unreliable, see author's notes

		require("jdtls.setup").add_commands()

		-- Enable and refresh codelens
		-- vim.lsp.codelens.refresh()
		-- vim.api.nvim_create_autocmd("BufWritePost", {
		-- 	pattern = { "*.java" },
		-- 	callback = function()
		-- 		pcall(vim.lsp.codelens.refresh)
		-- 		pcall(vim.diagnostic.setqflist)
		-- 	end,
		-- })

		-- Filter "target/" folder from diagnostics
		local orig_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
		vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, res, ctx, config)
			-- res = { uri, diagnostics = { { code, message, range, severity }, ...} }
			if res and res.uri:match("/target/") then
				res.diagnostics = {}
			end
			orig_handler(err, res, ctx, config)
		end

	end

	return {
		name = "jdtls",
		cmd = cmd,
		root_dir = root_dir,
		settings = settings,
		capabilities = capabilities,
		init_options = init_options,
		on_attach = on_attach,
	}
end

local function attach()
	local state = vim.g.session_state["lang.java.jdtls"] or {}
	local config = state.config
	if config == nil then
		config = get_setup_config()
		state.config = config
		vim.g.session_state["lang.java.jdtls"] = state
	end
	require("jdtls").start_or_attach(config)
end

return {
	attach = attach,
}
