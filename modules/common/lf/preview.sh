FILE="$1"

WIDTH="$2"
WIDTH=$((WIDTH - 1)) # if drawbox option is enabled
HEIGHT="$3"
X="$4"
Y="$5"

# exclude rclone mount directory
case "$FILE" in
    /Users/dominic/rcloneMount/*) exit 0;;
esac


case "$(file --mime-type --dereference --brief "$FILE")" in
  video/*)
    mediainfo "$FILE"
    ;;
  audio/*)
    mediainfo "$FILE"
    ;;
  image/*)
    kitty +icat --silent --transfer-mode file --place "${WIDTH}x${HEIGHT}@${X}x${Y}" "$FILE"
    exit 1   # invoke cleaner
    ;;
  *)
    pistol "$FILE"
    ;;
esac

exit 0


