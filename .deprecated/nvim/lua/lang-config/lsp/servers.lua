local pload = function(path)
  local status, lang_config = pcall(require, path)
  if not status then
    return {}
  end
  return lang_config
end

return {
  lua_ls = {
    exeName = "lua-language-server",
    config = pload("lang-config/lsp/setup/lua")
  },
  clangd = {
    exeName = "clangd",
    config = pload("lang-config/lsp/setup/cpp"),
  },
  bashls = {
    exeName = "bash-language-server",
    config = pload("lang-config/lsp/setup/bash"),
  },
  tsserver = {
    exeName = "typescript-language-server",
    config = pload("lang-config/lsp/setup/ts"),
  },
  pyright = {
    exeName = "pyright",
    config = pload("lang-config/lsp/setup/python"),
  },
  rust_analyzer = {
    exeName = "rust-analyzer",
    config = pload("lang-config/lsp/setup/rust")
  },
  nil_ls = {
    exeName = "nil",
    config = pload("lang-config/lsp/setup/nix")
  }
}
