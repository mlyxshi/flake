const ARG = Deno.args;
const BARK_KEY = Deno.env.get("BARK_KEY");

const TORRENT_NAME = ARG[0];
const CONTENT_PATH = ARG[1];
const FILES_NUM = ARG[2];
const TORRENT_SIZE = ARG[3];
const FILE_HASH = ARG[4];
const CATEGORY = ARG[5];

// console.log("ARG:", ARG);
// console.log("BARK_KEY:", BARK_KEY);
// console.log("TORRENT_NAME:", TORRENT_NAME);
// console.log("CONTENT_PATH:", CONTENT_PATH);
// console.log("FILES_NUM:", FILES_NUM);
// console.log("TORRENT_SIZE:", TORRENT_SIZE/1024/1024,"MB");
// console.log("FILE_HASH:", FILE_HASH);
// console.log("CATEGORY:", CATEGORY);

// const MEDIA_URL = encodeURIComponent(`http://bangumi-index.mlyxshi.com/${TORRENT_NAME}`);
// const IOS_SHORTCUTS_URL = encodeURIComponent(`shortcuts://run-shortcut?name=qbittorrent-delete&input=text&text=${FILE_HASH}`)
// const INFUSE_URL_SCHEME = `infuse://x-callback-url/play?url=${MEDIA_URL}&x-success=${IOS_SHORTCUTS_URL}`;

fetch(
    `https://api.day.app/push`,
    {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            device_key: BARK_KEY,
            title: "Swiftfin",
            icon: "https://github.com/jellyfin/Swiftfin/raw/main/Swiftfin/Assets.xcassets/AppIcon.appiconset/152.png",
            body: TORRENT_NAME,
            // url: "",
        }),
    },
);