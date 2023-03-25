local treesitter = require "nvim-treesitter.configs"

treesitter.setup({

  -- TreeSitter Parser from nixpkgs
  -- ensure_installed = require("lang-config.treesitter.parsers"),

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true,
  },

})
