{ pkgs, lib, config, osConfig, ... }: {
  home.file.".config/helix".source =
    if osConfig.settings.nixConfigDir == null
    then ../config/helix
    else config.lib.file.mkOutOfStoreSymlink "${osConfig.settings.nixConfigDir}/config/helix";
}
