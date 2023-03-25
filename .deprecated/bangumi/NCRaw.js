const REGEX = /(不當哥哥了|轉生公主與天才千金的魔法革命|異世界悠閒農家)/;
const NC_URL = "https://t.me/NC_Raws_Channel"
const FALLBACK_DESCRIPTION = "推送发布通知并自动上传到TG"

const TG_ID = Deno.env.get("ID")
const TG_TOKEN = Deno.env.get("TOKEN")

const MINUTES = 10
const INTERVAL = MINUTES * 60 * 1000;

let ID = 20000  //initial ID
let FAIL = false
let FAIL_COUNT = 0

async function FN() {
    while (FAIL_COUNT < 5) {
        ID++;
        const response = await fetch(`${NC_URL}/${ID}`);
        const html = await response.text();
        //console.log(html);
        const name = html.match(/meta property="og:description" content="(.*)/) || ["", FALLBACK_DESCRIPTION ]
        // I don't know why "> will appear
        if (name[1].includes(FALLBACK_DESCRIPTION) || name[1]==`">`) {
            // 不存在或已被删除的message
            if (FAIL) FAIL_COUNT++;
            FAIL = true;
        } else {
            // 正常message
            console.log(ID + ": " + name[1])
            FAIL = false;
            FAIL_COUNT = 0;
            //hardcode Chinese sub
            if (html.includes("HardSub") && REGEX.test(name[1])) fetch(`https://api.telegram.org/bot${TG_TOKEN}/sendMessage?chat_id=${TG_ID}&parse_mode=html&text=${name[1]}%0A${NC_URL}/${ID}`)
        }
    }

    ID -= 6;
    FAIL = false;
    FAIL_COUNT = 0;
    console.log("----------------------------------------")
}

FN();
setInterval(FN, INTERVAL);