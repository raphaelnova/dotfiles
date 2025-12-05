require("lang.java.jdtls").setup_or_attach()

vim.opt.tabstop = 4

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  desc = "Installs Java treesitter parser if not installed already.",
  callback = function()
    local parser = "java"
    local loaded, ts_install = pcall(require, "nvim-treesitter.install")
    if loaded and not ts_install.is_installed(parser) then
      ts_install.install(parser)
    end
  end,
})

-- TODO: Add specific keymaps and which-key group

-- Register prefixes for the different keymaps we have setup previously
-- which_key.register({
-- 	{ "<leader>/", group = "Comments"   }, { "<leader>/_", hidden = true },
-- 	{ "<leader>J", group = "[J]ava"     }, { "<leader>J_", hidden = true },
-- 	{ "<leader>c", group = "[C]ode"     }, { "<leader>c_", hidden = true },
-- 	{ "<leader>d", group = "[D]ebug"    }, { "<leader>d_", hidden = true },
-- 	{ "<leader>e", group = "[E]xplorer" }, { "<leader>e_", hidden = true },
-- 	{ "<leader>f", group = "[F]ind"     }, { "<leader>f_", hidden = true },
-- 	{ "<leader>g", group = "[G]it"      }, { "<leader>g_", hidden = true },
-- 	{ "<leader>w", group = "[W]indow"   }, { "<leader>w_", hidden = true },
-- })

-- TODO: Add Mason binaries

-- Formatters and linters
local null_ls = require("null-ls")
null_ls.register({
	null_ls.builtins.formatting.google_java_format,
	null_ls.builtins.formatting.xmllint,
})
