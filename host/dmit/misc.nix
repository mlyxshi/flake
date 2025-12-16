{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  fileSystems."/old-root" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
    options = [ "X-mount.subdir=new-root" ];
  };
  fileSystems."/nix" = {
    device = "/dev/vda1";
    fsType = "ext4";
    options = [ "X-mount.subdir=nix" ];
  };

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "update" ''
      if [[ -e "/flake/flake.nix" ]]
      then
        cd /flake
        git pull   
      else
        git clone --depth=1  git@github.com:mlyxshi/flake /flake
        cd /flake
      fi  


      SYSTEM=$(nix build --no-link --print-out-paths .#nixosConfigurations.$HOST.config.system.build.toplevel)

      if [ -n "$SYSTEM" ]
      then
        [[ -e "/run/current-system" ]] && nix store diff-closures /run/current-system $SYSTEM
        cat <<END > /boot/grub/custom.cfg
        menuentry "NixOS" --id NixOS {
          insmod ext2
          search -f /etc/hostname --set root
          linux $SYSTEM/kernel root=fstab $(cat $SYSTEM/kernel-params) init=$SYSTEM/init
          initrd $SYSTEM/initrd
        }
        set default="NixOS"
        END
      else
        echo "Build Failed"
        exit 1
      fi
    '')

  ];

}
