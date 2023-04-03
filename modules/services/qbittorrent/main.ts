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

const INFUSE_PLAYER_URL = encodeURIComponent(`http://bangumi-index.mlyxshi.com/${TORRENT_NAME}`);

fetch(
    `https://api.day.app/push`,
    {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            device_key: BARK_KEY,
            title: "Infuse",
            icon: "https://static.firecore.com/images/infuse/infuse-icon_2x.png",
            body: TORRENT_NAME,
            url: `infuse://x-callback-url/play?url=${INFUSE_PLAYER_URL}`,
        }),
    },
);