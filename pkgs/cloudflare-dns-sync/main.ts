const DOMAINS = Deno.args;
// console.log("DOMAINS:", DOMAINS);

const ZONE_ID = Deno.env.get("ZONE_ID");
// console.log("TOKEN:", ZONE_ID);

const TOKEN = Deno.env.get("TOKEN");
// console.log("TOKEN:", TOKEN);

const LocalIP = await(await fetch("https://api.ipify.org")).text();
// console.log("LocalIP:", LocalIP);


for (const DOMAIN of DOMAINS) {

  const response = await fetch(
    `https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${DOMAIN}`,
    {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${TOKEN}`,
      },
    },
  );

  const responseBody = await response.json();
  // console.log(responseBody);
  // console.log(responseBody.result_info.count);

  function createDNSRecord() {
    fetch(
      `https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${TOKEN}`,
        },
        body: JSON.stringify({
          type: "A",
          name: DOMAIN,
          content: LocalIP,
          ttl: 1,
          proxied: false,
        }),
      },
    );
  }

  function updateDNSRecord(Id: string) {
    fetch(
      `https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${Id}`,
      {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${TOKEN}`,
        },
        body: JSON.stringify({
          type: "A",
          name: DOMAIN,
          content: LocalIP,
          ttl: 1,
          proxied: false,
        }),
      },
    );
  }

  if (responseBody.result_info.count === 0) {
    console.log(`%c${DOMAIN} | DNS Not Registered, Create DNS Record Now`, "color: blue");
    createDNSRecord();
  } else {
    const Id = responseBody.result[0].id;
    // console.log("DNS-ID:", Id);

    const Content = responseBody.result[0].content;
    // console.log("Content:", Content);

    if (Content !== LocalIP) {
      console.log(`%c${DOMAIN} | DNS IP Not Match, Update DNS Record Now`, "color: yellow");
      updateDNSRecord(Id);
    } else {
      console.log(`%c${DOMAIN} | DNS IP Match, Do Nothing`, "color: green");
    }
  }
}