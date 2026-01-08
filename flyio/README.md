
mkdir -p /data/chats/696869490
/notifier repo-add nixpkgs https://github.com/NixOS/nixpkgs
/notifier repo-edit nixpkgs --branch-regex master|nixos-unstable|nixos-unstable-small
/notifier condition-add —type remove-if-in-branch —expr nixos-unstable nixpkgs in-nixos-unstable
/notifier pr-add https://github.com/NixOS/nixpkgs/pull/476546


### 切换到Debian
[build]
 

设置 /data 内容
debian可以ssh，fly ssh console

## cmd
fly volumes update vol_45lnw37w90my5oqr  --scheduled-snapshots=false
fly secrets list


flyctl deploy --ha=false

