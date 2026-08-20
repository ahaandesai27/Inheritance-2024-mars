/**
 * Blinkit search client.
 *
 * Why curl and not fetch(): blinkit.com sits behind Cloudflare bot management,
 * which rejects the request unless BOTH of these hold:
 *   1. the full browser header set is present (origin / referer / sec-fetch-* / UA), and
 *   2. the request is HTTP/2.
 * Node's global fetch (undici) is HTTP/1.1-only, so it always gets a 403 HTML
 * block page no matter which headers you set. Node's http2 module speaks h2 but
 * its TLS + SETTINGS fingerprint is still flagged. curl clears both bars, so we
 * shell out to it.
 */

const { execFile } = require("node:child_process");

const ENDPOINT = "https://blinkit.com/v1/layout/search";
const DEFAULT_LOCATION = { lat: "19.115171", lon: "72.901933" };
const UA =
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36";

function buildHeaders(query, { lat, lon }) {
    return {
        "content-type": "application/json",
        "accept": "*/*",
        "accept-language": "en-US,en;q=0.9",
        "app_client": "consumer_web",
        "web_app_version": "1008010016",
        "lat": lat,
        "lon": lon,
        "origin": "https://blinkit.com",
        "referer": `https://blinkit.com/s/?q=${encodeURIComponent(query)}`,
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-origin",
        "user-agent": UA,
    };
}

function curlPost(url, headers, body) {
    const args = ["--http2", "-s", "--compressed", "-X", "POST", url];
    for (const [k, v] of Object.entries(headers)) args.push("-H", `${k}: ${v}`);
    args.push("--data-binary", body);
    // append the HTTP status so we can tell a block page from real JSON
    args.push("-w", "\n__STATUS__%{http_code}");

    return new Promise((resolve, reject) => {
        execFile("curl", args, { maxBuffer: 32 * 1024 * 1024 }, (err, stdout) => {
            if (err) return reject(err);
            const i = stdout.lastIndexOf("\n__STATUS__");
            const status = Number(stdout.slice(i + "\n__STATUS__".length));
            resolve({ status, body: stdout.slice(0, i) });
        });
    });
}

/** Pull product cards out of Blinkit's nested widget/snippet payload. */
function parseProducts(payload) {
    const out = [];
    const seen = new Set();

    const walk = (node) => {
        if (!node || typeof node !== "object") return;
        if (Array.isArray(node)) return node.forEach(walk);

        const d = node.data;
        if (d && d.name?.text && d.normal_price?.text) {
            const id = String(d.identity?.id ?? d.product_id ?? d.name.text);
            if (!seen.has(id)) {
                seen.add(id);
                out.push({
                    productName: d.name.text,
                    productPrice: {
                        discountedPrice: toNumber(d.normal_price.text),
                        originalPrice: toNumber(d.mrp?.text) ?? toNumber(d.normal_price.text),
                    },
                    productWeight: d.variant?.text ?? null,
                    productImage: d.image?.url ?? null,
                    productLink: `https://blinkit.com/prn/x/prid/${id}`,
                    inStock: d.inventory > 0,
                    origin: "blinkit",
                });
            }
        }
        for (const v of Object.values(node)) walk(v);
    };

    walk(payload.response?.snippets ?? payload);
    return out;
}

// prices arrive as rendered strings like "₹78" / "₹1,299"
function toNumber(text) {
    if (!text) return null;
    const n = Number(String(text).replace(/[^0-9.]/g, ""));
    return Number.isFinite(n) && n > 0 ? n : null;
}

/**
 * Search Blinkit. Pages through results until `limit` products are collected.
 * @returns {Promise<Array>} normalized products
 */
async function searchBlinkit(query, opts = {}) {
    const location = { ...DEFAULT_LOCATION, ...opts };
    const limit = opts.limit ?? 30;
    const headers = buildHeaders(query, location);

    const products = [];
    let offset = 0;
    let pageIndex = 0;
    let postbackParams = "";

    while (products.length < limit && pageIndex < 5) {
        const url =
            `${ENDPOINT}?q=${encodeURIComponent(query)}&search_type=type_to_search` +
            `&offset=${offset}&limit=12&page_index=${pageIndex}`;
        const body = JSON.stringify({
            applied_filters: null,
            previous_search_query: "",
            processed_rails: {},
            postback_params: postbackParams,
        });

        const res = await curlPost(url, headers, body);
        if (res.status !== 200) {
            throw new Error(`Blinkit returned HTTP ${res.status} (Cloudflare block page?)`);
        }

        let payload;
        try {
            payload = JSON.parse(res.body);
        } catch {
            throw new Error("Blinkit returned non-JSON (likely an HTML block page)");
        }

        const batch = parseProducts(payload);
        const before = products.length;
        for (const p of batch) {
            if (!products.some((x) => x.productLink === p.productLink)) products.push(p);
        }
        if (products.length === before) break; // no new products -> end of results

        postbackParams = payload.postback_params ?? "";
        offset += 12;
        pageIndex += 1;
    }

    return products.slice(0, limit);
}

module.exports = { searchBlinkit, parseProducts };

// CLI:  node blinkitfetch.js paneer
if (require.main === module) {
    const query = process.argv[2] || "paneer";
    searchBlinkit(query)
        .then((products) => {
            require("fs").writeFileSync("blinkit.json", JSON.stringify(products, null, 2));
            console.log(`${products.length} products -> blinkit.json`);
            for (const p of products.slice(0, 10)) {
                console.log(
                    `  ${p.productName} | ${p.productWeight} | ` +
                    `₹${p.productPrice.discountedPrice} (mrp ₹${p.productPrice.originalPrice})`
                );
            }
        })
        .catch((e) => {
            console.error("FAILED:", e.message);
            process.exit(1);
        });
}
