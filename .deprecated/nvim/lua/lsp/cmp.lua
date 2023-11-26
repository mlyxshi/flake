local cmp = require "cmp"
local lspconfig = require "lspconfig"
local  luasnip = require "luasnip"
require("neodev").setup()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = cmp.config.sources(
    {
      { name = "nvim_lsp" },
      { name = "luasnip" },
    },
    {
      { name = "buffer" },
      { name = "path" }
    }
  ),
  formatting = require('lsp.ui').formatting,
  mapping = require("keybindings").cmp(cmp),
})

cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})



--lua don't have continue, so we have to use strange 'repeat until' way to simulate it.
for server_name, lang_config in pairs(require("lang-config.lsp.servers")) do

  repeat
    -------------------------------------------------------------------------------
    --- continue part
    local exeName = lang_config.exeName
    if vim.fn.executable(exeName) == 0 then
      -- vim.notify("LSP ".. exeName.." Not Found")
      break
    end
    -------------------------------------------------------------------------------
    --- normal loop part
    local config = {
      on_attach = function(client, bufnr)  
        require("keybindings").LSP_on_attach(client, bufnr)
      end,
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
    }
    config.settings = lang_config.config
    lspconfig[server_name].setup(config)
    -------------------------------------------------------------------------------
  until true

end
