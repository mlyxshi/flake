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
  
  boot.loader.grub.devices="nodev"; # dmit original grub -> nixos systemd-initrd

  # https://gist.github.com/dramforever/bf339cb721d25892034e052765f931c6
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
        nix-env -p /nix/var/nix/profiles/system --set $SYSTEM
        
        cat <<END > /old-root/boot/grub/custom.cfg
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
