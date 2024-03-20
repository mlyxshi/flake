{ config, pkgs, lib, self, ... }: {
  imports = [ self.nixosModules.services.hydra.aarch64 ];

  environment.systemPackages = [
    # (pkgs.writeShellScriptBin "os-dd" ''
    #   [[ -e "/persist/flake/flake.nix" ]] || git clone --depth=1  git@github.com:mlyxshi/flake /persist/flake

    #   cd /persist/flake
    #   git pull 

    #   image=$(nix build --no-link --print-out-paths .#nixosConfigurations.$1.config.system.build.image)

    #   if [ -n "$image" ]
    #   then
    #     dd if=$image/image.raw bs=5M conv=fsync status=progress | gzip -1 -c | \
    #       ssh -o StrictHostKeyChecking=no root@$2 \
    #       "gzip -d | dd of=/dev/sda bs=5M && mount /dev/sda2 /tmp && mkdir -p /tmp/persist/sops/ && curl -sLo /tmp/persist/sops/key $3 && reboot"
    #   else
    #     echo "Build Failed"
    #     exit 1
    #   fi
    # '')
  ];
}
