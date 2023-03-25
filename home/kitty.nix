{ pkgs, lib, config, osConfig, ... }: {
  home.file.".config/kitty".source = config.lib.file.mkOutOfStoreSymlink "${osConfig.settings.nixConfigDir}/config/kitty";
}
