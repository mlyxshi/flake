{
  config,
  pkgs,
  lib,
  ...
}:
{

  virtualisation.oci-containers.containers.commit-notifier = {
    image = "ghcr.io/mlyxshi/commit-notifier-arm64";
    volumes = [ "/var/lib/commit-notifier:/data" ];
    environmentFiles = [ /secret/commit-notifier ];
    extraOptions = [
      "--label"
      "io.containers.autoupdate=registry"
    ];
  };

  # mkdir -p /var/lib/commit-notifier/chats/696869490
  # /notifier repo-add nixpkgs https://github.com/NixOS/nixpkgs
  # /notifier repo-add systemd https://github.com/systemd/systemd
}

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
#     "master-to-staging-next": {
#       "condition": {
#         "SuppressFromTo": {
#           "from_regex": "^master$",
#           "to_regex": "^staging-next$"
#         }
#       }
#     },
#     "staging-next-to-staging": {
#       "condition": {
#         "SuppressFromTo": {
#           "from_regex": "^staging-next$",
#           "to_regex": "^staging$"
#         }
#       }
#     }
#   }
# }