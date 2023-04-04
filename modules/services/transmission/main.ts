#!/usr/bin/env -S deno run --allow-net --allow-env
const BARK_KEY = Deno.env.get("BARK_KEY");

const TR_TORRENT_NAME = Deno.env.get("TR_TORRENT_NAME");
const TR_TORRENT_ID = Deno.env.get("TR_TORRENT_ID");
const TR_TORRENT_LABELS = Deno.env.get("TR_TORRENT_LABELS");

console.log("TR_TORRENT_NAME:", TR_TORRENT_NAME);
console.log("TR_TORRENT_ID:", TR_TORRENT_ID);
console.log("TR_TORRENT_LABELS:", TR_TORRENT_LABELS);

const MEDIA_URL = encodeURIComponent(`http://transmission-index.mlyxshi.com/${TR_TORRENT_NAME}`);
const IOS_SHORTCUTS_URL = encodeURIComponent(`shortcuts://run-shortcut?name=transmission-delete&input=text&text=${TR_TORRENT_ID}`)
const INFUSE_URL_SCHEME = `infuse://x-callback-url/play?url=${MEDIA_URL}&x-success=${IOS_SHORTCUTS_URL}`;

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
            body: TR_TORRENT_NAME,
            url: INFUSE_URL_SCHEME,
            copy: INFUSE_URL_SCHEME,
        }),
    },
);