-- vim.opt.tabstop = 4
require("config.jdtls").setup_or_attach()

-- It doesn't work like that, we have to call it for every new buffer
-- in order to attach the running LSP to it.
-- local function setup_jdtls_once()
--   local root = vim.fs.root(0, { ".git", "pom.xml", "mvnw", "gradlew", "build.gradle" })
--   for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
--     print(client.name)
--     if client.config and client.config.root_dir == root then
--       return -- already running
--     end
--   end
--   require("config.jdtls").setup_or_attach()
-- end
--
-- setup_jdtls_once()
