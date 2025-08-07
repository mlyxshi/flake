### Nix
```
curl -sL https://install.determinate.systems/nix | sh -s -- install 
nix profile install nixpkgs#nixos-install-tools 
nixos-generate-config 
```

### Darwin
```
curl -sL https://install.determinate.systems/nix | sh -s -- install --determinate
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
git clone --depth=1  https://github.com/mlyxshi/flake.git ~/flake


defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
defaults write com.apple.finder RelativeDates -bool false

defaults write NSGlobalDomain NSStatusItemSpacing -int 6
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict-add "1" "yyyy-MM-dd HH:mm"
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict-add "2" "yyyy-MM-dd HH:mm:ss"
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict-add "3" "yyyy-MM-dd HH:mm:ss"
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict-add "4" "yyyy-MM-dd HH:mm:ss"


# change default shell to fish
sudo bash -c 'echo "/run/current-system/sw/bin/fish" >> /etc/shells' 
chsh -s /run/current-system/sw/bin/fish dominic
```


### Todo