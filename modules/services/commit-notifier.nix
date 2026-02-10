{
  pkgs,
  ...
}:
{
  systemd.services.commit-notifier = {
    path = [
      pkgs.gitMinimal
    ];
    environment = {
      RUST_LOG = "info";
    };

    serviceConfig = {
      EnvironmentFile = "/secret/commit-notifier";
      StateDirectory = "commit-notifier";
      ExecStart = "${pkgs.commit-notifier}/bin/commit-notifier --working-dir /var/lib/commit-notifier  --cron '0 * * * * *'   --admin-chat-id=696869490";
    };

    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };
}

# mkdir -p /var/lib/commit-notifier/chats/696869490
# /notifier repo-add nixpkgs https://github.com/NixOS/nixpkgs
# /notifier repo-add systemd https://github.com/systemd/systemd

#  /var/lib/commit-notifier/repositories/nixpkgs/settings.json

# {
#   "branch_regex": "^(master|nixos-unstable-small|staging|staging-next)$",
#   "github_info": {
#     "owner": "NixOS",
#     "repo": "nixpkgs"
#   },
#   "conditions": {
#     "in-nixos-unstable-small": {
#       "condition": {
#         "InBranch": {
#           "branch_regex": "^nixos-unstable-small$"
#         }
#       }
#     },
#     "master-to-staging-next-to-staging": {
#       "condition": {
#         "SuppressFromTo": {
#           "from_regex": "^master$",
#           "to_regex": "^(staging-next|staging)$"
#         }
#       }
#     }
#   }
# }