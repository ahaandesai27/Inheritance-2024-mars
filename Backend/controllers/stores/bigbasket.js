const { toProduct } = require('./normalize');

const HOME_URL = 'https://www.bigbasket.com/';
const SEARCH_URL = 'https://www.bigbasket.com/listing-svc/v2/products';
const PRODUCT_BASE = 'https://www.bigbasket.com';
const USER_AGENT =
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36';
const MAX_PAGES = 5;

async function getSessionCookie() {
  const response = await fetch(HOME_URL, { headers: { 'user-agent': USER_AGENT } });
  return response.headers
    .getSetCookie()
    .map((cookie) => cookie.split(';')[0])
    .join('; ');
}

function normalize(product) {
  const discount = product.pricing?.discount;
  const availability = product.availability;
  const link = product.absolute_url || '';

  return toProduct({
    name: product.desc,
    price: discount?.prim_price?.sp,
    mrp: discount?.mrp,
    weight: product.w,
    image: product.images?.[0]?.m,
    // absolute_url is relative, e.g. "/pd/40130385/fresho-tomato/"
    link: link && !link.startsWith('http') ? `${PRODUCT_BASE}${link}` : link,
    brand: product.brand?.name,
    inStock: availability?.avail_status === '001' && availability?.not_for_sale !== true,
    origin: 'bigbasket',
  });
}

async function bigBasketSearch(query, options = {}) {
  const limit = options.limit ?? 30;
  const cookie = options.cookie ?? (await getSessionCookie());

  const products = [];
  let lastPage = 1;

  for (let page = 1; page <= lastPage && products.length < limit; page++) {
    const url = `${SEARCH_URL}?type=ps&slug=${encodeURIComponent(query)}&page=${page}`;
    const response = await fetch(url, { headers: { 'user-agent': USER_AGENT, cookie } });

    if (!response.ok) throw new Error(`BigBasket returned HTTP ${response.status}`);

    // asking for a page past the end answers 204 with an empty body
    const text = await response.text();
    if (!text) break;

    const data = JSON.parse(text);
    const info = data.tabs?.[0]?.product_info;
    const batch = info?.products || [];
    if (batch.length === 0) break;

    lastPage = Math.min(info.number_of_pages || 1, MAX_PAGES);
    for (const product of batch) products.push(normalize(product));
  }

  return products.slice(0, limit);
}

module.exports = bigBasketSearch;
