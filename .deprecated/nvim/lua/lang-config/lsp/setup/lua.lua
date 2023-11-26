-- https://github.com/sumneko/lua-language-server/blob/master/locale/en-us/setting.lua
-- Format indent follow shiftwidth
return {
  Lua = {
    runtime = {
      version = 'LuaJIT',
    },
    diagnostics = {
      globals = { 'vim' },
    },
    workspace = {
      library = vim.api.nvim_get_runtime_file("", true),
    },
    telemetry = {
      enable = false,
    },
  },
}
