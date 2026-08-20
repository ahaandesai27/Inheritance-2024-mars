# Underlying search APIs (captured via Chrome devtools/network + fetch instrumentation)

Findings from inspecting each site's live network traffic. Query used for all probes: `paneer`.

---

## BigBasket — JSON API available ✅ - works too 

```
GET https://www.bigbasket.com/listing-svc/v2/products?type=ps&slug=tomato&page=1
```

- Verified: HTTP 200, 40 products in one call.
- Response shape: `tabs[0].product_info.products[]`
- Per product: `desc` (name), `w` (weight), `pricing.discount.mrp`,
  `pricing.discount.prim_price.sp` (selling price), `images[0].s`, `absolute_url`.
- Optional `bucket_id` param appears in the site's own call (`&bucket_id=51`) but is not required.
- Replaces the DOM selectors in `scrapers/bigbasketScraper.js` (whose `.AypOi`/`.hsCgvu`
  hashed class names are Emotion-generated and break on every deploy).

## Starquik — Shopify JSON ✅  (⚠️ site migrated) - only this one works lol

```
GET https://www.starquik.com/search/suggest.json?q=<query>&resources[type]=product&resources[limit]=10
```

- Verified: HTTP 200, returns products with `title`, `price`, `compare_at_price_max`,
  `featured_image.url`, `url` (relative), `vendor`, `type`, `tags`.
- ⚠️ Starquik is now a **Shopify** storefront. The scraper's current base URL
  `https://www.starquik.com/search/<query>` returns **404**. Correct HTML path is
  `https://www.starquik.com/search?q=<query>`, and all selectors in
  `scrapers/starquikScraper.js` (`.product-card-*`) no longer exist.
- `suggest.json` caps at 10 results. For more, Shopify also exposes
  `/products.json?limit=250&page=N` (full catalog, not query-filtered).

## Blinkit — JSON API available ✅ (but needs curl, not fetch) ⚠️

```
POST https://blinkit.com/v1/layout/search?q=<query>&search_type=type_to_search
```

**Working client: `store-api/blinkitfetch.js`** (`node blinkitfetch.js paneer` → 30 products).

blinkit.com sits behind **Cloudflare bot management**, which rejects the call unless
**both** of these hold:

1. **The full browser header set is present** — not just the app headers. Missing
   `origin` / `referer` / `sec-fetch-*` / a real `user-agent` / `accept` ⇒ 403.
2. **The request is HTTP/2.** This is the part that bites: HTTP/1.1 with byte-identical
   headers still returns 403.

Isolated by bisecting (query `paneer`, same headers throughout):

| client | HTTP version | result |
|---|---|---|
| `curl` + full headers | h2 | **200** ✅ |
| `curl` + full headers | 1.1 | 403 ❌ |
| `curl` + app headers only | h2 | 403 ❌ |
| Node global `fetch` (undici) + full headers | 1.1 only | 403 ❌ |
| Node `http2` module + full headers | h2 | 403 ❌ |

So **Node's global `fetch()` can never work here** — undici is HTTP/1.1-only. Node's
built-in `http2` module clears the HTTP/2 bar but is still blocked, because Cloudflare
also fingerprints the TLS ClientHello (JA3) and the h2 SETTINGS frame, and Node's TLS
API gives you no way to reshape either. Forcing IPv4 vs IPv6 makes no difference.

**Fix: shell out to `curl`** (`--http2`), which clears both bars. `blinkitfetch.js`
does this via `child_process.execFile`. Requires `curl` on the box — add it to the
Dockerfile (`node:22-slim` does not ship it):

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
```

Alternatives if you would rather not shell out: `node-libcurl` (same TLS stack as curl),
a JA3-impersonating client such as `cycletls`, or reusing the existing Puppeteer setup.

Required headers:

| header | value |
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
| `lat` / `lon` | e.g. `19.115171` / `72.901933` (store selection is header-based) |

Body: `{"applied_filters":null,"previous_search_query":"","processed_rails":{}}`

- Products are nested inside widget snippets — walk the tree for nodes with both
  `data.name.text` and `data.normal_price.text` rather than indexing fixed positions.
- Prices are rendered strings with a `₹` prefix (and thousands commas) — strip before parsing.
- Pagination: `offset` / `limit` / `page_index` (site uses `offset=12&limit=12`), feeding
  `postback_params` from the previous response forward. One page ≈ 12 products.
- Note: `api/controller.js` already advertises `blinkit` in its error message but no
  Blinkit scraper is registered.

---

## DMart Ready — JSON API available ✅ (cleanest of the four) 🆕

```
GET https://digital.dmart.in/api/v3/search/<query>?page=1&size=50&buryOOS=true&channel=web&storeId=10151
```

**Working client: `store-api/dmartfetch.js`** (`node dmartfetch.js paneer` → 25 products).

- **No auth, no cookies, no special headers** — plain Node `fetch()` works, unlike Blinkit.
  Verified 200 with literally zero request headers set.
- `storeId` selects the catalogue and pricing region. Optional, but different stores carry
  different products (`10151` = Andheri, Mumbai → 32 hits for `paneer`; `10001` → 0), so pin it.
- `buryOOS=true` pushes out-of-stock items to the end. `page` is **1-indexed**.
- Response: `{ totalRecords, products[] }`. Each product holds one or more `sKUs[]`
  (200 g / 500 g / …), and **price lives on the SKU, not the product** — so flatten to one
  entry per SKU.
- Per SKU: `name`, `priceMRP`, `priceSALE`, `variantTextValue` (weight), `skuUniqueID`,
  `productImageKey`, `imgCode`, `buyable`, `availabilityType` (`"A"` = available).
- Image URL: `https://cdn.dmart.in/images/products/{productImageKey}_{imgCode}_P.jpg`
  — note this uses the **flat** `productImageKey`, *not* the slash-delimited `imageKey`.
- Product URL: `https://www.dmart.in/product/{seo_token_ntk}?selectedProd={skuUniqueID}`
- Both URL forms verified HTTP 200.

---

## Summary

| Site | Usable JSON API | Client | Endpoint |
|---|---|---|---|
| BigBasket | ✅ yes | `fetch` ok | `GET /listing-svc/v2/products?type=ps&slug=<q>&page=1` |
| Starquik | ✅ yes (Shopify) | `fetch` ok | `GET /search/suggest.json?q=<q>&resources[type]=product` |
| **DMart Ready** | ✅ yes | **`fetch` ok** | `GET digital.dmart.in/api/v3/search/<q>?storeId=10151` |
| Blinkit | ✅ yes | **curl only (h2)** | `POST /v1/layout/search?q=<q>` |

Four working sources: **BigBasket, Starquik, DMart, Blinkit.**

**Also flagged while checking:** Starquik has changed platform and URL scheme since
`scrapers/starquikScraper.js` was written, so it is almost certainly returning `null`
today regardless of which approach is used.
