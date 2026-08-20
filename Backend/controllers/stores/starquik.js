const { toProduct } = require('./normalize');

const SEARCH_URL = 'https://www.starquik.com/search/suggest.json';
const PRODUCT_BASE = 'https://www.starquik.com';
const MAX_RESULTS = 10; 

function weightFromTitle(title) {
  const match = String(title || '').match(/(\d+(?:\.\d+)?)\s*(kg|gm|g|ml|ltr|l|pcs|pc)\b/i);
  return match ? `${match[1]} ${match[2].toLowerCase()}` : null;
}

function normalize(product) {
  const path = product.url ? product.url.split('?')[0] : '';

  return toProduct({
    name: product.title,
    price: product.price,
    mrp: product.compare_at_price_max,
    weight: weightFromTitle(product.title),
    image: product.featured_image?.url || product.image,
    link: path ? `${PRODUCT_BASE}${path}` : null,
    brand: product.vendor,
    inStock: product.available === true,
    origin: 'starquik',
  });
}

async function starquikSearch(query, options = {}) {
  const limit = Math.min(options.limit ?? MAX_RESULTS, MAX_RESULTS);
  const url =
    `${SEARCH_URL}?q=${encodeURIComponent(query)}` +
    `&resources[type]=product&resources[limit]=${limit}`;

  const response = await fetch(url, { headers: { accept: 'application/json' } });
  if (!response.ok) throw new Error(`Starquik returned HTTP ${response.status}`);

  const data = await response.json();
  const products = data.resources?.results?.products || [];

  return products.map(normalize);
}

module.exports = starquikSearch;
