const { execFile } = require('node:child_process');
const { toProduct } = require('./normalize');

const SEARCH_URL = 'https://blinkit.com/v1/layout/search';
const PRODUCT_BASE = 'https://blinkit.com/prn/x/prid';
const USER_AGENT =
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36';
const DEFAULT_LOCATION = { lat: '19.115171', lon: '72.901933' };
const PAGE_SIZE = 12;
const MAX_PAGES = 5;

function buildHeaders(query, location) {
  return {
    'content-type': 'application/json',
    accept: '*/*',
    'accept-language': 'en-US,en;q=0.9',
    app_client: 'consumer_web',
    web_app_version: '1008010016',
    lat: location.lat,
    lon: location.lon,
    origin: 'https://blinkit.com',
    referer: `https://blinkit.com/s/?q=${encodeURIComponent(query)}`,
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-origin',
    'user-agent': USER_AGENT,
  };
}

function curlPost(url, headers, body) {
  const args = ['--http2', '-s', '--compressed', '-X', 'POST', url];
  for (const [key, value] of Object.entries(headers)) args.push('-H', `${key}: ${value}`);
  args.push('--data-binary', body);
  args.push('-w', '\n__STATUS__%{http_code}');

  return new Promise((resolve, reject) => {
    execFile('curl', args, { maxBuffer: 32 * 1024 * 1024 }, (error, stdout) => {
      if (error) return reject(error);
      const marker = stdout.lastIndexOf('\n__STATUS__');
      resolve({
        status: Number(stdout.slice(marker + '\n__STATUS__'.length)),
        body: stdout.slice(0, marker),
      });
    });
  });
}

function parseProducts(payload) {
  const products = [];
  const seen = new Set();

  const walk = (node) => {
    if (!node || typeof node !== 'object') return;
    if (Array.isArray(node)) return node.forEach(walk);

    const data = node.data;
    if (data?.name?.text && data?.normal_price?.text) {
      const id = String(data.identity?.id ?? data.product_id ?? data.name.text);

      if (!seen.has(id)) {
        seen.add(id);
        products.push(
          toProduct({
            name: data.name.text,
            price: data.normal_price.text,
            mrp: data.mrp?.text,
            weight: data.variant?.text,
            image: data.image?.url,
            link: `${PRODUCT_BASE}/${id}`,
            brand: data.brand_name?.text,
            inStock: data.inventory > 0,
            origin: 'blinkit',
          })
        );
      }
    }

    for (const value of Object.values(node)) walk(value);
  };

  walk(payload.response?.snippets ?? payload);
  return products;
}

async function blinkitSearch(query, options = {}) {
  const limit = options.limit ?? 30;
  const location = { ...DEFAULT_LOCATION, ...options };
  const headers = buildHeaders(query, location);

  const products = [];
  const seen = new Set();
  let postbackParams = '';

  for (let page = 0; page < MAX_PAGES && products.length < limit; page++) {
    const url =
      `${SEARCH_URL}?q=${encodeURIComponent(query)}&search_type=type_to_search` +
      `&offset=${page * PAGE_SIZE}&limit=${PAGE_SIZE}&page_index=${page}`;
    const body = JSON.stringify({
      applied_filters: null,
      previous_search_query: '',
      processed_rails: {},
      postback_params: postbackParams,
    });

    const response = await curlPost(url, headers, body);
    if (response.status !== 200) {
      throw new Error(`Blinkit returned HTTP ${response.status} (Cloudflare block page?)`);
    }

    let payload;
    try {
      payload = JSON.parse(response.body);
    } catch {
      throw new Error('Blinkit returned non-JSON (likely an HTML block page)');
    }

    let added = 0;
    for (const product of parseProducts(payload)) {
      if (seen.has(product.productLink)) continue;
      seen.add(product.productLink);
      products.push(product);
      added++;
    }
    if (added === 0) break; // nothing new on this page, so we're at the end

    postbackParams = payload.postback_params ?? '';
  }

  return products.slice(0, limit);
}

module.exports = blinkitSearch;
