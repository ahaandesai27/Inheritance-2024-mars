const puppeteer = require('puppeteer');
// sample url https://www.swiggy.com/instamart/search?custom_back=true&query=almonds

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
    const productImages = Array.from(document.querySelectorAll('img._1NxA5')).map(el => el.src);

    return productPrices.map((price, index) => ({
      productName: productNames[index] || 'N/A',
      productPrice: price || 'N/A',
      productWeight: productWeights[index] || 'N/A',
      productImage: productImages[index] || 'N/A',
      origin: "swiggy"
    }));
  });

  if (products.length === 0) {
    console.warn("No product names found. Check your selectors.");
  }

  await browser.close();
  return products;
}

module.exports = swiggyScraper;
