# from https://github.com/NixOS/nixpkgs/pull/351699/files
# An interactive image built using systemd-repart.
#
# This is a higher-level abstraction built on top of repart.nix but designed
# to give you an interactive (i.e. with Nix available and working image.) image.
#
# You can use this by importing this module in your config.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
let

  closureInfo = pkgs.closureInfo {
    rootPaths = [ config.system.build.toplevel ];
  };

  # Build the nix state at /nix/var/nix for the image
  #
  # This does two things:
  # (1) Setup the initial profile
  # (2) Create an initial Nix DB so that the nix tools work
  nixState = pkgs.runCommand "nix-state" { nativeBuildInputs = [ pkgs.buildPackages.nix ]; } ''
    mkdir -p $out/profiles
    ln -s ${config.system.build.toplevel} $out/profiles/system-1-link
    ln -s /nix/var/nix/profiles/system-1-link $out/profiles/system

    export NIX_STATE_DIR=$out
    nix-store --load-db < ${closureInfo}/registration
  '';
in
{

  imports = [ "${modulesPath}/image/repart.nix" ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-partlabel/nixos";
      fsType = "ext4";
    };
  };
  boot.loader.systemd-boot.enable = true;
  nixpkgs.hostPlatform = "aarch64-linux";

  system.image = {
    id = config.system.name;
    version = config.system.nixos.version;
  };

  image.repart = {
    name = config.system.name;
    partitions = {
      "esp" = {
        contents =
          let
            efiArch = config.nixpkgs.hostPlatform.efiArch;
          in
          {
            "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
              "${config.systemd.package}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

            "/EFI/Linux/${config.system.boot.loader.ukiFile}".source =
              "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
          };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          Label = "boot";
          SizeMinBytes = "200M";
        };
      };
      "root" = {
        storePaths = [ config.system.build.toplevel ];
        contents = {
          "/nix/var/nix".source = nixState;
        };
        repartConfig = {
          Type = "root";
          Format = "ext4";
          Label = "nixos";
          Minimize = "guess";
        };
      };
    };
  };

}
