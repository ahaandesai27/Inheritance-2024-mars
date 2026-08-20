/**
 * DMart Ready search client.
 *
 * Open JSON API — no auth, no cookies, no special headers, and plain Node
 * fetch() works (unlike Blinkit, which needs curl for HTTP/2). This is the
 * cleanest of the four sources.
 *
 *   GET https://digital.dmart.in/api/v3/search/<query>
 *       ?page=1&size=50&buryOOS=true&channel=web&storeId=10151
 *
 * storeId selects the catalogue/pricing region — it is optional, but different
 * stores carry different products, so pin it. 10151 = Andheri, Mumbai.
 * `buryOOS=true` pushes out-of-stock items to the end (what the site itself sends).
 */

const ENDPOINT = "https://digital.dmart.in/api/v3/search";
const DEFAULT_STORE_ID = "10151";
const IMAGE_BASE = "https://cdn.dmart.in/images/products";
const PRODUCT_BASE = "https://www.dmart.in/product";

/**
 * A DMart "product" holds one or more SKUs (200 g / 500 g / ...). Each SKU has
 * its own price, so we flatten to one entry per SKU — that matches how the
 * other stores report results.
 */
function normalize(product) {
    return (product.sKUs || []).map((sku) => ({
        productName: sku.name || product.name,
        productPrice: {
            discountedPrice: toNumber(sku.priceSALE) ?? toNumber(sku.priceMRP),
            originalPrice: toNumber(sku.priceMRP),
        },
        productWeight: sku.variantTextValue || null,
        productImage: sku.productImageKey
            ? `${IMAGE_BASE}/${sku.productImageKey}_${sku.imgCode || "5"}_P.jpg`
            : null,
        productLink: product.seo_token_ntk
            ? `${PRODUCT_BASE}/${product.seo_token_ntk}?selectedProd=${sku.skuUniqueID}`
            : null,
        brand: product.manufacturer || null,
        // invStatus "2" = in stock; availabilityType "A" = available
        inStock: sku.buyable === "true" && sku.availabilityType === "A",
        origin: "dmart",
    }));
}

function toNumber(text) {
    if (text === undefined || text === null || text === "") return null;
    const n = Number(String(text).replace(/[^0-9.]/g, ""));
    return Number.isFinite(n) && n > 0 ? n : null;
}

/**
 * Search DMart Ready.
 * @param {string} query
 * @param {{limit?:number, storeId?:string}} opts
 * @returns {Promise<Array>} normalized products (one entry per SKU)
 */
async function searchDmart(query, opts = {}) {
    const limit = opts.limit ?? 30;
    const storeId = opts.storeId ?? DEFAULT_STORE_ID;

    const products = [];
    for (let page = 1; page <= 5 && products.length < limit; page++) {
        const url =
            `${ENDPOINT}/${encodeURIComponent(query)}` +
            `?page=${page}&size=50&buryOOS=true&channel=web&storeId=${storeId}`;

        const res = await fetch(url, { headers: { accept: "application/json" } });
        if (!res.ok) throw new Error(`DMart returned HTTP ${res.status}`);

        const data = await res.json();
        const batch = data.products || [];
        if (batch.length === 0) break;

        for (const p of batch) products.push(...normalize(p));

        // totalRecords tells us when we've exhausted the result set
        if (data.totalRecords && products.length >= data.totalRecords) break;
    }

    return products.slice(0, limit);
}

module.exports = { searchDmart, normalize };

// CLI:  node dmartfetch.js paneer
if (require.main === module) {
    const query = process.argv[2] || "paneer";
    searchDmart(query)
        .then((products) => {
            require("fs").writeFileSync("dmart.json", JSON.stringify(products, null, 2));
            console.log(`${products.length} products -> dmart.json`);
            for (const p of products.slice(0, 10)) {
                console.log(
                    `  ${p.productName} | ₹${p.productPrice.discountedPrice} ` +
                    `(mrp ₹${p.productPrice.originalPrice})${p.inStock ? "" : "  [OOS]"}`
                );
            }
        })
        .catch((e) => {
            console.error("FAILED:", e.message);
            process.exit(1);
        });
}
