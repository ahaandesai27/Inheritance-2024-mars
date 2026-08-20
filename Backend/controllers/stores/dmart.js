const { toProduct } = require('./normalize');

const SEARCH_URL = 'https://digital.dmart.in/api/v3/search';
const IMAGE_BASE = 'https://cdn.dmart.in/images/products';
const PRODUCT_BASE = 'https://www.dmart.in/product';
const DEFAULT_STORE_ID = '10151';
const PAGE_SIZE = 50;
const MAX_PAGES = 5;

function normalize(product) {
  return (product.sKUs || []).map((sku) =>
    toProduct({
      name: sku.name || product.name,
      price: sku.priceSALE,
      mrp: sku.priceMRP,
      weight: sku.variantTextValue,
      image: sku.productImageKey
        ? `${IMAGE_BASE}/${sku.productImageKey}_${sku.imgCode || '5'}_P.jpg`
        : null,
      link: product.seo_token_ntk
        ? `${PRODUCT_BASE}/${product.seo_token_ntk}?selectedProd=${sku.skuUniqueID}`
        : null,
      brand: product.manufacturer,
      inStock:
        sku.buyable === 'true' && sku.availabilityType === 'A' && sku.invStatus !== '0',
      origin: 'dmart',
    })
  );
}

async function dmartSearch(query, options = {}) {
  const limit = options.limit ?? 30;
  const storeId = options.storeId ?? DEFAULT_STORE_ID;

  const products = [];

  for (let page = 1; page <= MAX_PAGES && products.length < limit; page++) {
    const url =
      `${SEARCH_URL}/${encodeURIComponent(query)}` +
      `?page=${page}&size=${PAGE_SIZE}&buryOOS=true&channel=web&storeId=${storeId}`;

    const response = await fetch(url, { headers: { accept: 'application/json' } });
    if (!response.ok) throw new Error(`DMart returned HTTP ${response.status}`);

    const data = await response.json();
    const batch = [...(data.products || []), ...(data.oosProducts || [])];
    if (batch.length === 0) break;

    for (const product of batch) products.push(...normalize(product));
  }

  return products.slice(0, limit);
}

module.exports = dmartSearch;
