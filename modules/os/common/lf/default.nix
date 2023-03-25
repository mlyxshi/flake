{ pkgs, ... }: {
  environment.etc."lf/lfrc".text = (''
    set previewer ${pkgs.writeShellScript "lf-previewer" (builtins.readFile ./preview.sh)}
    set cleaner ${pkgs.writeShellScript "lf-cleaner" (builtins.readFile ./cleaner.sh)}
  '' + builtins.readFile ./lfrc);
}
