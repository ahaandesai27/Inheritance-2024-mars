const API_URL =
    "https://www.bigbasket.com/listing-svc/v2/products?type=ps&slug=tomato&page=1";

async function main() {
    const response = await fetch(API_URL, {
        headers: {
            "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
            "accept-language": "en-US,en;q=0.6",
            "cache-control": "max-age=0",
            "cookie": "_bb_locSrc=default; x-channel=web; _bb_aid=MjkxMzA4NDUzMA==; _bb_cid=1; _bb_vid=MTM5NDA0Mzk0NTE0MjY0ODA0Ng==; _bb_nhid=7427; _bb_dsid=7427; _bb_dsevid=7427; _bb_bhid=; _bb_loid=; csrftoken=YzuF50rPei1p4VZlL74YVceFhhkN2ss2rf52x8MGioCz6gu3RKbXTOCCVpAEUT07; _bb_bb2.0=1; is_global=1; _bb_addressinfo=; _bb_pin_code=; _bb_sa_ids=19224; _is_tobacco_enabled=1; _is_bb1.0_supported=0; _bb_cda_sa_info=djIuY2RhX3NhLjEwLjE5MjI0; is_integrated_sa=1; is_subscribe_sa=0; _bb_member_class=; bb2_enabled=true; jarvis-id=3f7004f0-5851-4a25-874e-650cb4859490; bigbasket.com=4979df4c-3708-48a9-acb8-c1d3e5739930; ts=2026-08-19%2022:28:28.395; csurftoken=md5uYA.MTM5NDA0Mzk0NTE0MjY0ODA0Ng==.1787160201898.8vxGVoJKPCy2pCefT88hM8w8B38L2d1b3JmbW3+uCCs=",
            "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36"
        }
    });

    console.log(response.status);

    const data = await response.json();

    const fs = require("fs");
    fs.writeFileSync("bb.json", JSON.stringify(data, null, 2));
}

main();