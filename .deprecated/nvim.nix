{ pkgs, lib, osConfig, config, ... }:
let
  # the special plugin which contains parsers  <-- need compile
  # use folke/lazy to manage other plugins

  treesitter-parsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p;[ c lua nix bash json typescript python ])).dependencies;
  };

in
{
  xdg.configFile = {
    "nvim/init.lua".text = ''

      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "--single-branch",
          "https://github.com/folke/lazy.nvim.git",
          lazypath,
        })
      end

      vim.opt.runtimepath:prepend(lazypath)

      vim.g.mapleader = " "
      
      require("lazy").setup("plugins")

      vim.opt.runtimepath:append("${treesitter-parsers}")

      require("start")
    '';
  };

  home.file.".config/nvim/lua".source =
    if osConfig.settings.nixConfigDir == null
    then ../config/nvim/lua
    else config.lib.file.mkOutOfStoreSymlink "${osConfig.settings.nixConfigDir}/config/nvim/lua";


  home.packages = lib.optionals osConfig.settings.developerMode [
    pkgs.nil #nix-lsp
    pkgs.lua-language-server #lua-language-server
    # clang-tools # clangd
    # nodePackages.bash-language-server #bash
    # nodePackages.pyright #python
    # rust-analyzer #rust

    # nodePackages.typescript #Typescript
    # nodePackages.typescript-language-server

    # cargo #Rust
    # rustc
  ];
}
