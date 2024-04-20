const BARK_KEY = Deno.env.get("BARK_KEY");
const ADMIN = Deno.env.get("ADMIN");
const PASSWORD = Deno.env.get("PASSWORD");

const TR_TORRENT_DIR = Deno.env.get("TR_TORRENT_DIR");
const TR_TORRENT_NAME = Deno.env.get("TR_TORRENT_NAME");
const TR_TORRENT_ID = Deno.env.get("TR_TORRENT_ID");
const TR_TORRENT_LABELS = Deno.env.get("TR_TORRENT_LABELS");

const FUll_PATH = `${TR_TORRENT_DIR}/${TR_TORRENT_NAME}`
const FILE_INFO = await Deno.stat(FUll_PATH);

// const RCLONE_FOLDER = "gdrive:Download"

console.log("TR_TORRENT_NAME:", TR_TORRENT_NAME);
console.log("TR_TORRENT_ID:", TR_TORRENT_ID);
console.log("TR_TORRENT_LABELS:", TR_TORRENT_LABELS);
console.log("TR_TORRENT_DIR:", TR_TORRENT_DIR);
console.log("FILE_INFO:", FILE_INFO)


// if (TR_TORRENT_LABELS == "rss") {
//     Deno.run({ cmd: ["transmission-remote", "--auth", `${ADMIN}:${PASSWORD}`, "--torrent", TR_TORRENT_ID, "--remove"], });
//     fetch(`https://api.day.app/push`, {
//         method: "POST",
//         headers: { "Content-Type": "application/json", },
//         body: JSON.stringify({
//             device_key: BARK_KEY,
//             title: "Jellyfin",
//             icon: "https://avatars.githubusercontent.com/u/45698031",
//             body: TR_TORRENT_NAME,
//         }),
//     },);
// }

// else {
//     let cmd = "";
//     if (FILE_INFO.isFile) cmd = ["rclone", "copy", FUll_PATH, RCLONE_FOLDER];
//     if (FILE_INFO.isDirectory) cmd = ["rclone", "copy", "--transfers", "32", FUll_PATH, `${RCLONE_FOLDER}/${TR_TORRENT_NAME}`];
//     const RCLONE_PROCESS = Deno.run({ cmd });
//     await RCLONE_PROCESS.status();

//     fetch(`https://api.day.app/push`, {
//         method: "POST",
//         headers: { "Content-Type": "application/json", },
//         body: JSON.stringify({
//             device_key: BARK_KEY,
//             title: "Upload",
//             icon: "https://drive.google.com/favicon.ico",
//             body: TR_TORRENT_NAME,
//         }),
//     },);


//     if (TR_TORRENT_LABELS != "seed") Deno.run({ cmd: ["transmission-remote", "--auth", `${ADMIN}:${PASSWORD}`, "--torrent", TR_TORRENT_ID, "--remove-and-delete"], });
// }

