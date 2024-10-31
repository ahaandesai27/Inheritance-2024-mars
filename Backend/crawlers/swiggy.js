const puppeteer = require('puppeteer');

async function swiggyScraper(query) {
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();
  const startUrl = `https://www.swiggy.com/instamart/search?custom_back=true&query=${query}`;

  await page.goto(startUrl, { waitUntil: 'domcontentloaded' });
  console.log(`Navigating to: ${startUrl}`);

  // Wait for the product elements to load
  await page.waitForSelector('._1sPB0'); 
  await page.waitForSelector('.JZGfZ'); 

  const products = await page.evaluate(() => {
    const productNames = Array.from(document.querySelectorAll('._1sPB0')).map(el => el.innerText);
    const productPrices = Array.from(document.querySelectorAll('.JZGfZ')).map(el => el.innerText);
    const productWeights = Array.from(document.querySelectorAll('._3eIPt')).map(el => el.innerText);
    const productImage = Array.from(document.querySelectorAll('img._1NxA5')).map(el => el.src);

    return productPrices.map((price, index) => ({
      product_name: productNames[index] || 'N/A',
      product_prices: price || 'N/A',
      productWeights: productWeights[index] || 'N/A',
      productImage: productImage[index] || 'N/A'
    }));
  });

  if (products.length === 0) {
    console.warn("No product names found. Check your selectors.");
  }

  await browser.close();
  return products;
}

module.exports = swiggyScraper;
