# https://github.com/figsoda/cfg/blob/6318590ac96ac7590095430a9a601b07367c6dd3/install#L14
src=$(dirname "$(realpath "$0")")/config
echo "Creating Symlinks for $HOME"
echo "Source Folder: $src"
fd --base-directory "$src" --hidden --type f --exec  \
    sh -c "mkdir -p '$HOME/{//}' && ln -sf '$src/{}' '$HOME/{}'"
