function findCheapestProduct(products, query) {
  return products.reduce((minProduct, currentProduct) => {

    if (!currentProduct.productName || currentProduct.productPrice.originalPrice === null || 
        !currentProduct.productName?.toLowerCase().includes(query.toLowerCase())) {
      return minProduct;
    }

    return currentProduct.productPrice.originalPrice < minProduct.productPrice.originalPrice
      ? currentProduct
      : minProduct;
  }, { productPrice: { originalPrice: Infinity } });  
}

module.exports = findCheapestProduct;
