// Each store API answers with its own field names and its own quirks. These two
// helpers are what keep all four store clients returning the exact same shape.

// Prices come back as strings everywhere: plain ("95.00"), or rendered for
// display with a rupee sign and commas ("₹1,299"). Strip anything that is not
// part of the number.
function toNumber(text) {
  if (text === undefined || text === null || text === '') return null;
  const number = Number(String(text).replace(/[^0-9.]/g, ''));
  return Number.isFinite(number) && number > 0 ? number : null;
}

// The one shape every store client returns. Fields a store does not provide are
// null, never missing, so callers can read them without checking first.
function toProduct({ name, price, mrp, weight, image, link, brand, inStock, origin }) {
  const sellingPrice = toNumber(price);
  const listPrice = toNumber(mrp);

  return {
    productName: name || null,
    productPrice: {
      // if only one of the two is on offer, use it for both
      discountedPrice: sellingPrice ?? listPrice,
      originalPrice: listPrice ?? sellingPrice,
    },
    productWeight: weight || null,
    productImage: image || null,
    productLink: link || null,
    brand: brand || null,
    inStock: Boolean(inStock),
    origin,
  };
}

module.exports = { toProduct, toNumber };
