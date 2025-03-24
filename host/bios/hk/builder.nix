{ config, pkgs, lib, ... }: {

  environment.systemPackages = with pkgs;[
    (writeShellScriptBin "remote-update" ''
      if [[ -e "/flake/flake.nix" ]]
      then
        cd /flake
        git pull   
      else
        git clone --depth=1  git@github.com:mlyxshi/flake /flake
        cd /flake
      fi  

      HOST=''$1

      SYSTEM=$(nix build --no-link --print-out-paths .#nixosConfigurations.$HOST.config.system.build.toplevel)

      if [ -n "$SYSTEM" ]
      then
        nix copy --to ssh://$HOST $outPath
        ssh $HOST nix-env -p /nix/var/nix/profiles/system --set $outPath
        ssh $HOST $outPath/bin/switch-to-configuration switch
      else
        echo "Build Failed"
        exit 1
      fi
    '')
  ];



}
