{
  pkgs ? import <nixpkgs> { },
}:
rec {
  transmission = pkgs.callPackage ./transmission.nix { };

  commit-notifier = pkgs.callPackage ./commit-notifier.nix { };
  commit-notifier-container = pkgs.dockerTools.buildImage {
    name = "commit-notifier";
    copyToRoot = pkgs.buildEnv {
      name = "commit-notifier-env";
      paths =
        (with pkgs; [
          git
          coreutils 
        ])
        ++ (with pkgs.dockerTools; [
          usrBinEnv
          binSh
          caCertificates
        ]);
    };
    config = {
      Entrypoint = [
        "${pkgs.tini}/bin/tini"
        "--"
      ];
      Cmd = [
        "${commit-notifier}/bin/commit-notifier"
        "--working-dir"
        "/data"
        "--cron"
        "0 * * * * *"
        "--admin-chat-id=696869490"
      ];
      Env = [
        "TELOXIDE_TOKEN="
        "GITHUB_TOKEN="
        "RUST_LOG=commit_notifier=info"
      ];
      WorkingDirectory = "/data";
      Volumes = {
        "/data" = { };
      };
    };
  };
}
# nix-update commit-notifier --version=branch
# nix-update transmission
