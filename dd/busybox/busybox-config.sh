# https://bugs.busybox.net/show_bug.cgi?id=10296
while IFS= read -r sym || [ -n "$sym" ]; do
  case "$sym" in
    ''|\#*) continue ;;
  esac

  key="CONFIG_${sym}"

  sed -i "/^# $key is not set/d" .config

  echo "$key=y" >> .config

done < busybox.config