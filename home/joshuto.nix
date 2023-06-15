{ pkgs, lib, osConfig, config, ... }: {
  home.file.".config/joshuto".source =
    if osConfig.settings.nixConfigDir == null
    then ../config/joshuto
    else config.lib.file.mkOutOfStoreSymlink "${osConfig.settings.nixConfigDir}/config/joshuto";
}
