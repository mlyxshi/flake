function busybox_merge_config() {
  while read -r NAME OPTION || [[ -n $NAME ]]; do
    [[ $NAME =~ ^CONFIG_ ]] || continue
    echo "parseconfig: removing $NAME"
    sed -i "/^$NAME=/d" .config
    sed -i "/^# $NAME is not set/d" .config
    echo "parseconfig: setting $NAME=$OPTION"
    if [ "$OPTION" = "n" ]; then
      echo "# $NAME is not set" >> .config
    else
      echo "$NAME=$OPTION" >> .config
    fi
  done
}
