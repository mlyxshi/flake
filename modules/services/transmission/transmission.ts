const BARK_KEY = Deno.env.get("BARK_KEY");
const ADMIN = Deno.env.get("ADMIN");
const PASSWORD = Deno.env.get("PASSWORD");

const TR_TORRENT_NAME = Deno.env.get("TR_TORRENT_NAME");
const TR_TORRENT_ID = Deno.env.get("TR_TORRENT_ID");
const TR_TORRENT_LABELS = Deno.env.get("TR_TORRENT_LABELS");

const FUll_PATH = `/var/lib/transmission/files/${TR_TORRENT_NAME}`
const FILE_INFO = await Deno.stat(FUll_PATH);

const RCLONE_FOLDER = "gdrive:Download"

console.log("TR_TORRENT_NAME:", TR_TORRENT_NAME);
console.log("TR_TORRENT_ID:", TR_TORRENT_ID);
console.log("TR_TORRENT_LABELS:", TR_TORRENT_LABELS);
console.log("FILE_INFO:", FILE_INFO)

function isSingleVideo(str) {
    const videoSuffix = ['.mp4', '.avi', '.mkv', '.mov', '.flv', '.wmv', '.webm'];
    return videoSuffix.some(suffix => str.endsWith(suffix));
}

if (TR_TORRENT_LABELS == "rss") {
    Deno.run({ cmd: ["transmission-remote", "--auth", `${ADMIN}:${PASSWORD}`, "--torrent", TR_TORRENT_ID, "--remove"], });
} else if (FILE_INFO.isFile && isSingleVideo(TR_TORRENT_NAME)) {
    const MEDIA_URL = encodeURIComponent(`http://transmission-index.mlyxshi.com/${TR_TORRENT_NAME}`);
    const IOS_SHORTCUTS_URL = encodeURIComponent(`shortcuts://run-shortcut?name=transmission-delete&input=text&text=${TR_TORRENT_ID}`)
    const INFUSE_URL_SCHEME = `infuse://x-callback-url/play?url=${MEDIA_URL}&x-success=${IOS_SHORTCUTS_URL}`;

    fetch(`https://api.day.app/push`, {
        method: "POST",
        headers: { "Content-Type": "application/json", },
        body: JSON.stringify({
            device_key: BARK_KEY,
            title: "Infuse",
            icon: "https://static.firecore.com/images/infuse/infuse-icon_2x.png",
            body: TR_TORRENT_NAME,
            url: INFUSE_URL_SCHEME,
            copy: INFUSE_URL_SCHEME,
        }),
    },);

} else {
    let cmd = "";
    if (FILE_INFO.isFile) cmd = ["rclone", "copy", FUll_PATH, RCLONE_FOLDER];
    if (FILE_INFO.isDirectory) cmd = ["rclone", "copy", "--transfers", "32", FUll_PATH, `${RCLONE_FOLDER}/${TR_TORRENT_NAME}`];
    const RCLONE_PROCESS = Deno.run({ cmd });
    await RCLONE_PROCESS.status();

    fetch(`https://api.day.app/push`, {
        method: "POST",
        headers: { "Content-Type": "application/json", },
        body: JSON.stringify({
            device_key: BARK_KEY,
            title: "Upload",
            icon: "https://drive.google.com/favicon.ico",
            body: TR_TORRENT_NAME,
        }),
    },);


    if (TR_TORRENT_LABELS != "seed") Deno.run({ cmd: ["transmission-remote", "--auth", `${ADMIN}:${PASSWORD}`, "--torrent", TR_TORRENT_ID, "--remove-and-delete"], });
}

