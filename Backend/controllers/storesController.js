const { stores, storeNames } = require('./stores');
const { cacheGet, cacheSet } = require('../config/redis');

const DEFAULT_LIMIT = 30;
const MAX_LIMIT = 100;
// One slow store should not hold up the whole comparison, so every client gets
// its own budget and anything still running when it expires is reported failed.
const STORE_TIMEOUT_MS = 15000;

function parseLimit(raw) {
  const limit = parseInt(raw, 10);
  if (!Number.isFinite(limit) || limit < 1) return DEFAULT_LIMIT;
  return Math.min(limit, MAX_LIMIT);
}

// `?stores=bigbasket,dmart` narrows the fan-out. Returns every store when the
// param is absent, or a list of unknown names for the caller to complain about.
function parseStores(raw) {
  if (!raw) return { selected: storeNames, unknown: [] };

  const requested = String(raw)
    .split(',')
    .map((name) => name.trim().toLowerCase())
    .filter(Boolean);

  return {
    selected: requested.filter((name) => stores[name]),
    unknown: requested.filter((name) => !stores[name]),
  };
}

// Only lat/lon (Blinkit) and storeId (DMart) are read by any client; the rest
// ignore whatever they do not recognise.
function searchOptions(query, limit) {
  return {
    limit,
    ...(query.lat && query.lon ? { lat: String(query.lat), lon: String(query.lon) } : {}),
    ...(query.storeId ? { storeId: String(query.storeId) } : {}),
  };
}

function withTimeout(promise, name) {
  let timer;
  const timeout = new Promise((_, reject) => {
    timer = setTimeout(() => reject(new Error(`${name} timed out after ${STORE_TIMEOUT_MS}ms`)), STORE_TIMEOUT_MS);
  });
  return Promise.race([promise, timeout]).finally(() => clearTimeout(timer));
}

// Runs the selected stores in parallel. A store that throws (Cloudflare block,
// upstream 5xx, timeout) turns into an entry with ok:false rather than sinking
// the whole request - partial results still make a usable comparison.
async function fanOut(names, query, options) {
  const settled = await Promise.allSettled(
    names.map((name) => withTimeout(stores[name](query, options), name))
  );

  return settled.map((result, index) => {
    const store = names[index];
    if (result.status === 'fulfilled') {
      return { store, ok: true, count: result.value.length, products: result.value };
    }
    return { store, ok: false, error: result.reason.message, count: 0, products: [] };
  });
}

// Everything that can change the response has to be in the key: the endpoint,
// the query, which stores were asked for (order included - it is the order the
// results come back in), and the options the store clients actually read.
function cacheKey(endpoint, q, names, options) {
  return [
    'prices',
    endpoint,
    String(q).trim().toLowerCase(),
    names.join(','),
    options.limit,
    options.lat ?? '',
    options.lon ?? '',
    options.storeId ?? '',
  ].join(':');
}

const price = (product) => product.productPrice?.discountedPrice ?? null;

// GET /api/stores
const getStores = (req, res) => {
    res.json({ stores: storeNames });
};

// GET /api/stores/search?q=paneer&stores=bigbasket,dmart&limit=30
const searchStores = async (req, res) => {
    const q = req.query.q;
    if (!q) {
        return res.status(400).json({ message: 'Query parameter "q" is required' });
    }

    const { selected, unknown } = parseStores(req.query.stores);
    if (unknown.length) {
        return res.status(400).json({
            message: `Unknown store(s): ${unknown.join(', ')}. Available: ${storeNames.join(', ')}`,
        });
    }

    const limit = parseLimit(req.query.limit);
    const options = searchOptions(req.query, limit);
    const key = cacheKey('search', q, selected, options);

    const cached = await cacheGet(key);
    if (cached) return res.json(cached);

    try {
        const results = await fanOut(selected, q, options);
        const count = results.reduce((total, result) => total + result.count, 0);

        // every store failing is an upstream outage, not an empty result set
        if (count === 0 && results.every((result) => !result.ok)) {
            return res.status(502).json({ message: 'All stores failed', query: q, results });
        }

        const payload = { query: q, limit, count, results };
        // a partial fan-out would pin today's answer to a store that was merely
        // having a bad minute, so only a clean sweep is worth keeping
        if (count > 0 && results.every((result) => result.ok)) {
            await cacheSet(key, payload);
        }

        res.json(payload);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// GET /api/stores/cheapest?q=paneer
// Flattens the fan-out and picks the lowest in-stock price, keeping only
// products whose name actually mentions the query - search endpoints happily
// return loosely related items that would otherwise win on price alone.
const getCheapest = async (req, res) => {
    const q = req.query.q;
    if (!q) {
        return res.status(400).json({ message: 'Query parameter "q" is required' });
    }

    const limit = parseLimit(req.query.limit);
    const options = searchOptions(req.query, limit);
    const key = cacheKey('cheapest', q, storeNames, options);

    const cached = await cacheGet(key);
    if (cached) return res.json(cached);

    try {
        const results = await fanOut(storeNames, q, options);
        const needle = q.toLowerCase();

        const candidates = results
            .flatMap((result) => result.products)
            .filter(
                (product) =>
                    product.inStock &&
                    price(product) !== null &&
                    product.productName?.toLowerCase().includes(needle)
            )
            .sort((a, b) => price(a) - price(b));

        if (candidates.length === 0) {
            return res.status(404).json({ message: 'No matching in-stock product found', query: q });
        }

        const payload = {
            query: q,
            cheapest: candidates[0],
            // the rest, so the client can show what it was cheapest against
            alternatives: candidates.slice(1),
        };
        // a store that failed might have been holding the actual cheapest price
        if (results.every((result) => result.ok)) {
            await cacheSet(key, payload);
        }

        res.json(payload);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// GET /api/stores/:store?q=paneer&limit=30
const searchStore = async (req, res) => {
    const store = req.params.store.toLowerCase();
    const search = stores[store];
    if (!search) {
        return res.status(404).json({
            message: `Unknown store "${req.params.store}". Available: ${storeNames.join(', ')}`,
        });
    }

    const q = req.query.q;
    if (!q) {
        return res.status(400).json({ message: 'Query parameter "q" is required' });
    }

    const limit = parseLimit(req.query.limit);
    const options = searchOptions(req.query, limit);
    const key = cacheKey('store', q, [store], options);

    const cached = await cacheGet(key);
    if (cached) return res.json(cached);

    try {
        const products = await withTimeout(search(q, options), store);

        const payload = { query: q, store, count: products.length, products };
        if (products.length > 0) {
            await cacheSet(key, payload);
        }

        res.json(payload);
    } catch (error) {
        // the failure is upstream's, so report it as a bad gateway
        res.status(502).json({ message: `${store} lookup failed`, error: error.message });
    }
};

module.exports = { getStores, searchStores, getCheapest, searchStore };
