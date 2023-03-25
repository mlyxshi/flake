#!/bin/bash
env

echo "Torrent Name：$TR_TORRENT_NAME" 
echo "Size：$(($TR_TORRENT_BYTES_DOWNLOADED/1024/1024)) MB"
echo "Category: $TR_TORRENT_LABELS"

RCLONE_FOLDER="gdrive:Download"
FUll_PATH="/download/files/$TR_TORRENT_NAME"
echo $FUll_PATH

# single file OR folder
[ -f "$FUll_PATH" ] && rclone -v copy "$FUll_PATH" $RCLONE_FOLDER || rclone -v copy --transfers 32 "$FUll_PATH" $RCLONE_FOLDER/"$TR_TORRENT_NAME"

# For any defined category, after download, upload to googledrive but do not auto delete(important resource, PT share ratio requirement)
[[ -n "$TR_TORRENT_LABELS" ]] || transmission-remote --auth $ADMIN:$PASSWORD --torrent $TR_TORRENT_ID --remove-and-delete 

MESSAGE="<b>GoogleDrive Upload Success</b>%0A"
MESSAGE+="$TR_TORRENT_NAME"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
curl -X POST $URL -d parse_mode=html -d chat_id=$ID -d text="$MESSAGE" >/dev/null
echo "-------------------------------------------------------------------------------------"