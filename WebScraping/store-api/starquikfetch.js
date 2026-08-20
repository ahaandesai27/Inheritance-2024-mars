const API_URL =
    "https://www.bigbasket.com/listing-svc/v2/products?type=ps&slug=tomato&page=1&lat-long=123";

const SOURCE = "bb";

async function main() {
    const response = await fetch(API_URL);

    console.log(response.status);

    const data = await response.json();

    const fs = require("fs");
    fs.writeFileSync(`${SOURCE}.json`, JSON.stringify(data, null, 2));
}

main();