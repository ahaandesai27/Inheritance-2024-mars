// The store clients all take (query, options) and answer with the same product
// shape (see normalize.js), so the routes only need this lookup to fan out.

const bigBasketSearch = require('./bigbasket');
const blinkitSearch = require('./blinkit');
const dmartSearch = require('./dmart');
const starquikSearch = require('./starquik');

const stores = {
  bigbasket: bigBasketSearch,
  blinkit: blinkitSearch,
  dmart: dmartSearch,
  starquik: starquikSearch,
};

const storeNames = Object.keys(stores);

module.exports = { stores, storeNames };
