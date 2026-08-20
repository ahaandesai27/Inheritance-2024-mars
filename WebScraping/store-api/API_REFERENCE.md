# Store Search APIs — Reference

The four grocery sources that expose a usable JSON search API, with the exact call
each one needs and the shape it returns.

All four were re-verified live on **2026-08-20** with query `paneer` (HTTP 200 each).

| Store | Method | Auth / gate | HTTP client | Implementation |
|---|---|---|---|---|
| [BigBasket](#1-bigbasket) | `GET` | session cookies (bootstrappable) | `fetch` ok | `bbfetch.js` |
| [Starquik](#2-starquik-shopify) | `GET` | none | `fetch` ok | *(none yet)* |
| [DMart Ready](#3-dmart-ready) | `GET` | none | `fetch` ok | `dmartfetch.js` |
| [Blinkit](#4-blinkit) | `POST` | Cloudflare — **needs HTTP/2** | **`curl` only** | `blinkitfetch.js` |

---

## 1. BigBasket

### Request

```
GET https://www.bigbasket.com/listing-svc/v2/products
```

| Param | Required | Value |
|---|---|---|
| `type` | ✅ | `ps` (product search) |
| `slug` | ✅ | the search query, URL-encoded |
| `page` | ✅ | 1-indexed |
| `bucket_id` | ✖ | site sends `51`; omitting it changes nothing |

**Cookies are required.** Without a session cookie jar the endpoint returns **400**
regardless of `user-agent` — an empty request, a UA-only request, and a UA + partial
cookie request all 400.

You do **not** need to hardcode a cookie header (as `bbfetch.js` currently does — that
jar is captured from a browser and will expire). Bootstrap one instead: `GET`
`https://www.bigbasket.com/` with a cookie jar, then reuse the jar. That single call
sets `_bb_vid`, `_bb_cid`, `_bb_aid`, `_bb_sa_ids`, `csrftoken`, `_bb_cda_sa_info` and
the rest, and the search call then returns 200. Verified — note the jar from the
homepage does **not** include `csurftoken`, so that token is not actually needed.

```bash
curl -s -c jar.txt -H "user-agent: <real Chrome UA>" https://www.bigbasket.com/ -o /dev/null
curl -s -b jar.txt -H "user-agent: <real Chrome UA>" \
  "https://www.bigbasket.com/listing-svc/v2/products?type=ps&slug=paneer&page=1"
```

⚠️ Rate-limited: rapid repeated calls start returning **429**. Space out requests and
treat 429 as retryable-with-backoff, distinct from the 400 you get with no cookies.

### Response

```jsonc
{
  "tabs": [
    {
      "product_info": {
        "products": [ /* see below */ ],   // 40 per page
        "page": 1,
        "number_of_pages": 7,
        "total_count": 261,
        "ps_or_search": false
      },
      "tab_info": {}, "search_info": {}, "filter_opts": [], "sort_opts": [], "bread_crumbs": []
    }
  ],
  "base_img_url": "https://www.bbassets.com/media/uploads",
  "screen_info": {}, "analytics_attrs": {}, "session_data": {}
}
```

Products live at `tabs[0].product_info.products[]`. Fields that matter:

```jsonc
{
  "id": "40215943",
  "desc": "Paneer",                          // product name
  "w": "1 kg",                               // pack weight, display string
  "magnitude": "1000",                       // numeric weight
  "unit": "g",
  "absolute_url": "/pd/40130385/fresho-tomato-.../",   // relative — prefix https://www.bigbasket.com
  "brand":  { "name": "fresho!", "slug": "fresho", "url": "/pb/fresho/" },
  "category": { "tlc_name": "Fruits & Vegetables", "mlc_name": "...", "llc_name": "..." },
  "availability": { "avail_status": "001", "button": "Add", "not_for_sale": false },
  "pricing": {
    "discount": {
      "mrp": "51",                           // strings, no ₹ prefix
      "d_text": "61% OFF",
      "d_avail": "true",
      "prim_price": {
        "sp": "20",                          // selling price — use this
        "rsp": "40.8",
        "base_price": "2",
        "base_unit": "100g"
      }
    }
  },
  "images": [ { "s": "...", "m": "...", "l": "...", "xl": "...", "xxl": "..." } ],
  "rating_info": {}, "inv_info": {}, "variant_info": [], "children": null
}
```

- Prices are **strings without a currency symbol**. `pricing.discount.prim_price.sp` is
  the selling price, `pricing.discount.mrp` the list price.
- Images are absolute CDN URLs already; `images[0].m` or `.l` is the usual pick.
- In stock ⇔ `availability.avail_status === "001"` and `not_for_sale === false`.
- Pagination: `number_of_pages` / `total_count` in `product_info`, 40 products per page.

---

## 2. Starquik (Shopify)

### Request

```
GET https://www.starquik.com/search/suggest.json
      ?q=<query>&resources[type]=product&resources[limit]=10
```

| Param | Required | Value |
|---|---|---|
| `q` | ✅ | the search query |
| `resources[type]` | ✅ | `product` — omit it and you also get `collections` and `pages` |
| `resources[limit]` | ✖ | max **10**, which is also the ceiling for this endpoint |

**No auth, no cookies, no headers.** Plain `fetch()` works.

⚠️ Starquik migrated to **Shopify**. `https://www.starquik.com/search/<query>` (the old
scraper's path) 404s; the HTML page is now `https://www.starquik.com/search?q=<query>`
and every `.product-card-*` selector in `scrapers/starquikScraper.js` is gone.

### Response

```jsonc
{
  "resources": {
    "results": {
      "products": [ /* see below */ ],
      "collections": [],   // only present if resources[type] is not pinned to product
      "pages": []
    }
  }
}
```

```jsonc
{
  "id": 9017458884829,
  "title": "Id Natural Paneer Pack 200 g",
  "handle": "id-natural-paneer-pack-200-gm-sc-sm36",
  "available": true,
  "price": "99.00",                     // strings, rupees, no symbol
  "price_min": "99.00",
  "price_max": "99.00",
  "compare_at_price_min": "140.00",     // MRP / struck-through price
  "compare_at_price_max": "140.00",
  "vendor": "Id",                       // brand
  "type": "Onion, Potato & Tomato",     // Shopify product type; often ""
  "tags": ["Dairy", "Paneer & Tofu", "veg", "..."],
  "body": "<p>HTML description</p>",
  "image": "https://cdn.shopify.com/s/files/.../SQ106793_FOP.jpg?v=1776845988",
  "featured_image": { "url": "...", "alt": "...", "width": 557, "height": 557, "aspect_ratio": 1 },
  "url": "/products/id-natural-paneer-pack-200-gm-sc-sm36?_pos=1&_psq=paneer&...",
  "variants": []                        // always empty on this endpoint
}
```

- `url` is **relative** — prefix `https://www.starquik.com`. The tracking query string
  (`_pos`/`_psq`/`_psid`/`_ss`) is safe to strip; the bare
  `https://www.starquik.com/products/<handle>` path is verified 200.
- Weight is not a field — it is baked into `title` (`"... Pack 200 g"`).
- In stock ⇔ `available === true`.
- No pagination and a hard cap of 10 results. For more, Shopify also exposes
  `/products.json?limit=250&page=N`, but that is the full catalog, **not** query-filtered.

---

## 3. DMart Ready

The cleanest of the four.

### Request

```
GET https://digital.dmart.in/api/v3/search/<query>
      ?page=1&size=50&buryOOS=true&channel=web&storeId=10151
```

| Param | Required | Value |
|---|---|---|
| `<query>` | ✅ | path segment, URL-encoded |
| `page` | ✅ | **1-indexed** |
| `size` | ✖ | page size; site uses `50` |
| `storeId` | ⚠️ | technically optional, but pin it — catalogue and pricing are per-store. `10151` = Andheri, Mumbai (32 hits for `paneer`); `10001` returns 0 |
| `buryOOS` | ✖ | `true` moves out-of-stock items into a separate `oosProducts[]` array |
| `channel` | ✖ | `web` |

**No auth, no cookies, no headers** — verified 200 with literally zero request headers.

### Response

```jsonc
{
  "totalRecords": 32,        // total PRODUCTS (not SKUs), incl. out-of-stock
  "products": [ ... ],       // 21 in-stock
  "oosProducts": [ ... ],    // 11 out-of-stock, same shape — split out by buryOOS=true
  "oosPosition": 0,
  "spellcheck": {}, "sortFilterData": {}, "dynamicListingContent": {}, "source": 1
}
```

A product is a *group*; **price lives on the SKU, not the product**, so flatten to one
entry per SKU (200 g / 500 g / …) to match the other stores.

```jsonc
{
  "productId": "367757",
  "name": "Amul Fresh Block Paneer",
  "manufacturer": "Amul",                                    // brand
  "seo_token_ntk": "amul-fresh-paneer-ppaneeramul5xx11218",  // for the product URL
  "targetUrl": "/pdp/367757",
  "buyable": "true",                                         // NB: strings, not booleans
  "availabilityType": "A",
  "numberOfskus": 1,
  "categoryMap": [ { "level": "L1", "name": "Dairy & Beverages" }, { "level": "L2", ... } ],
  "parentCategoryIds": ["110006", "93311", "93652"],
  "sKUs": [
    {
      "name": "Amul Fresh Paneer : 200 g",
      "skuUniqueID": "402006",
      "articleNumber": "130000535",
      "priceMRP": "95.00",
      "priceSALE": "88.00",          // selling price
      "savePrice": "7.00",
      "savingPercentage": 7,
      "variantTextValue": "200 g",   // weight
      "variantInfoTxtValue": "(₹ 0.44 / 1 g)",
      "buyable": "true",
      "availabilityType": "A",       // "A" = available
      "invStatus": "2",              // "2" = in stock
      "maxQuantity": "99",
      "tags": ["veg"],
      "productImageKey": "JUL130000535xx6JUL26vv200gm",   // flat key — use this one
      "imageKey": "J/U/L/JUL130000535xx6JUL26vv200gm",    // slash-delimited — NOT for URLs
      "imgCode": "5",
      "defaultVariant": "Y"
    }
  ]
}
```

Derived URLs (both verified 200):

```
image   https://cdn.dmart.in/images/products/{productImageKey}_{imgCode}_P.jpg
product https://www.dmart.in/product/{seo_token_ntk}?selectedProd={skuUniqueID}
```

- Booleans arrive as the **strings** `"true"` / `"false"`; prices as strings.
- In stock ⇔ `buyable === "true"` && `availabilityType === "A"`.
- ⚠️ `totalRecords` counts *products*, but a flattened result list counts *SKUs*, so
  `products.length >= totalRecords` is not a valid stop condition (`dmartfetch.js`
  currently does this). Stop when a page returns an empty `products[]` instead.
- ⚠️ With `buryOOS=true`, out-of-stock items are in `oosProducts[]`, which
  `dmartfetch.js` ignores — fine if you only want sellable items, but it means you see
  21 of the 32 matches.

---

## 4. Blinkit

### Request

```
POST https://blinkit.com/v1/layout/search
       ?q=<query>&search_type=type_to_search&offset=0&limit=12&page_index=0
```

| Param | Required | Value |
|---|---|---|
| `q` | ✅ | the search query |
| `search_type` | ✅ | `type_to_search` |
| `offset` / `limit` / `page_index` | ✖ | site uses `offset=12&limit=12`, `page_index` 0-indexed. ~12 products/page |

Body:

```json
{ "applied_filters": null, "previous_search_query": "", "processed_rails": {}, "postback_params": "" }
```

### Required headers

blinkit.com sits behind **Cloudflare bot management**. The call 403s unless **both** hold:
the full browser header set is present, **and** the request is HTTP/2.

| Header | Value |
|---|---|
| `content-type` | `application/json` |
| `accept` | `*/*` |
| `accept-language` | `en-US,en;q=0.9` |
| `user-agent` | a real Chrome UA |
| `origin` | `https://blinkit.com` |
| `referer` | `https://blinkit.com/s/?q=<query>` |
| `sec-fetch-dest` / `-mode` / `-site` | `empty` / `cors` / `same-origin` |
| `app_client` | `consumer_web` |
| `web_app_version` | `1008010016` |
| `lat` / `lon` | e.g. `19.115171` / `72.901933` — **store selection is header-based** |

Isolated by bisecting (query `paneer`, same headers throughout):

| client | HTTP version | result |
|---|---|---|
| `curl` + full headers | h2 | **200** ✅ |
| `curl` + full headers | 1.1 | 403 ❌ |
| `curl` + app headers only | h2 | 403 ❌ |
| Node global `fetch` (undici) + full headers | 1.1 only | 403 ❌ |
| Node `http2` module + full headers | h2 | 403 ❌ |

⚠️ **Node's global `fetch()` can never work here** — undici is HTTP/1.1-only, and
HTTP/1.1 with byte-identical headers still 403s. Node's `http2` module clears the h2 bar
but is still blocked, because Cloudflare also fingerprints the TLS ClientHello (JA3) and
the h2 SETTINGS frame, and Node's TLS API gives you no way to reshape either. Forcing
IPv4 vs IPv6 makes no difference.

**Fix:** `blinkitfetch.js` shells out to `curl --http2` via `child_process.execFile`,
which clears both bars. `curl` must be on the box — `node:22-slim` does not ship it:

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
```

Alternatives if you would rather not shell out: `node-libcurl` (same TLS stack as curl),
a JA3-impersonating client such as `cycletls`, or reusing the existing Puppeteer setup.

### Response

```jsonc
{
  "is_success": true,
  "response": {
    "snippets": [ /* mixed widgets */ ],
    "pagination": { "next_url": "/v1/layout/search?offset=12&limit=12&..." },
    "layout_config": {}, "tracking": {}, "page_actions": {},
    "page_level_components": {}, "subscribers": {}
  }
}
```

`snippets[]` is a **mixed widget list** — headers, banners and product cards interleaved
(`widget_type` is `image_text_vr_type_header`, `product_card_snippet_type_2`, …). Do not
index fixed positions; walk the tree for any node with both `data.name.text` and
`data.normal_price.text`, as `parseProducts()` in `blinkitfetch.js` does.

A product card's `data`:

```jsonc
{
  "identity":     { "id": "528454" },
  "product_id":   "528454",
  "name":         { "text": "Desi Farms Low Fat Paneer", "color": {...}, "font": {...} },
  "normal_price": { "text": "₹78" },        // selling price — RENDERED STRING
  "mrp":          { "text": "₹96" },        // list price
  "variant":      { "text": "200 g" },      // weight
  "image":        { "url": "https://cdn.grofers.com/da/cms-assets/cms/product/....png" },
  "offer_tag":    { "title": { "text": "18%\nOFF" } },
  "inventory":    1,
  "is_sold_out":  false,
  "brand_name":   { "text": "Desi Farms" },
  "display_name": { "text": "Desi Farms Low Fat Paneer" },   // same as name here
  "rating": {}, "merchant_id": "...", "eta_tag": {},
  "cta": {}, "atc_action": {}, "stepper_data": {}, "product_badges": []
}
```

- **Every display value is nested under `.text`** and prices are rendered strings with a
  `₹` prefix and thousands commas (`"₹1,299"`) — strip `[^0-9.]` before parsing.
- In stock ⇔ `inventory > 0` (`is_sold_out` is the equivalent flag).
- Product URL: `https://blinkit.com/prn/x/prid/{identity.id}` (verified 200).
- Pagination: bump `offset`/`page_index`, and feed the previous response's
  `postback_params` into the next request body. Stop when a page yields no new products.

---

## Normalized shape

`blinkitfetch.js` and `dmartfetch.js` already collapse their payloads to this common
shape; BigBasket and Starquik do not have a normalizing client yet.

```jsonc
{
  "productName": "Desi Farms Low Fat Paneer",
  "productPrice": {
    "discountedPrice": 78,      // number, rupees — selling price
    "originalPrice": 96         // number, rupees — MRP (falls back to selling price)
  },
  "productWeight": "200 g",     // null if the source has no weight field
  "productImage": "https://...",
  "productLink": "https://...",
  "brand": "Amul",              // dmart only so far
  "inStock": true,
  "origin": "blinkit"           // "blinkit" | "dmart" | "bigbasket" | "starquik"
}
```

| Field | BigBasket | Starquik | DMart (per SKU) | Blinkit |
|---|---|---|---|---|
| name | `desc` | `title` | `sKUs[].name` | `data.name.text` |
| selling price | `pricing.discount.prim_price.sp` | `price` | `sKUs[].priceSALE` | `data.normal_price.text` |
| MRP | `pricing.discount.mrp` | `compare_at_price_max` | `sKUs[].priceMRP` | `data.mrp.text` |
| weight | `w` | *(in `title`)* | `sKUs[].variantTextValue` | `data.variant.text` |
| image | `images[0].m` | `featured_image.url` | built from `productImageKey` | `data.image.url` |
| link | `absolute_url` (relative) | `url` (relative) | built from `seo_token_ntk` | built from `identity.id` |
| brand | `brand.name` | `vendor` | `manufacturer` | `data.brand_name.text` |
| in stock | `availability.avail_status === "001"` | `available` | `buyable`+`availabilityType` | `inventory > 0` |

Common gotchas: BigBasket, Starquik and DMart return **prices as strings**; Blinkit
returns them as **rendered strings with `₹`**; DMart returns **booleans as strings**;
BigBasket and Starquik return **relative product URLs**.

---

## Integration status

Where each of the four sits relative to the existing scraper/controller code.

| Store | Registered in `api/controller.js` | Existing scraper | Action |
|---|---|---|---|
| BigBasket | ✅ `bigbasket` | `scrapers/bigbasketScraper.js` | swap DOM parsing for the JSON API |
| Starquik | ✅ `starquik` | `scrapers/starquikScraper.js` | **broken** — rewrite against the JSON API |
| DMart | ❌ not registered | none | add scraper + register |
| Blinkit | ❌ not registered | none | add scraper + register |

- **BigBasket** — `bigbasketScraper.js` selects on `.AypOi` / `.hsCgvu`, which are
  Emotion-generated hashed class names and break on every site deploy. The JSON API
  replaces them outright.
- **Starquik** — `starquikScraper.js` is almost certainly returning `null` today: its
  base URL `https://www.starquik.com/search/<query>` 404s since the Shopify migration,
  and none of its `.product-card-*` selectors exist any more.
- **Blinkit** — `api/controller.js:39` already advertises `blinkit` in its error message
  (`'... (amazon, blinkit, zepto)'`), but no Blinkit scraper is registered in the source
  map. That error string is stale in both directions — it lists sources that aren't
  wired up and omits `bigbasket` / `starquik`, which are.
