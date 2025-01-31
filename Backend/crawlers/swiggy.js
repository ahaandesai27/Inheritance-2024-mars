const puppeteer = require('puppeteer');
const findCheapestProduct = require('./findsmallest.js')

async function swiggyScraper(query) {
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();
  const startUrl = `https://www.swiggy.com/instamart/search?custom_back=true&query=${query}`;

  console.log(`Navigating to: ${startUrl}`);
  await page.goto(startUrl, { waitUntil: 'networkidle2' });

  try {
    await page.waitForSelector('.sc-aXZVg.hwhxsS._1sPB0', { timeout: 10000 });
  } catch (error) {
    console.error("Error: Product elements did not load in time.");
    await browser.close();
    return [];
  }

  await page.evaluate(async () => {
    await new Promise((resolve) => {
      let totalHeight = 0;
      const distance = 200;
      const timer = setInterval(() => {
        const scrollHeight = document.body.scrollHeight;
        window.scrollBy(0, distance);
        totalHeight += distance;

        if (totalHeight >= scrollHeight) {
          clearInterval(timer);
          resolve();
        }
      }, 100);
    });
  });

  const products = await page.evaluate(() => {
    const productNames = Array.from(document.querySelectorAll('.sc-aXZVg.hwhxsS._1sPB0')).map(el => el.innerText.trim());
    const productPrices = Array.from(document.querySelectorAll('.JZGfZ')).map(el => el.innerText.trim());
    const discountedPrices = Array.from(document.querySelectorAll('._1MUgI')).map(el => el.innerText.trim());
    const productWeights = Array.from(document.querySelectorAll('._3eIPt')).map(el => el.innerText.trim());
    const productImages = Array.from(document.querySelectorAll('img._1NxA5')).map(el => el.src);

    return productNames.map((name, index) => {
      const ogprice = parseInt(productPrices[index])
      const discprice = parseInt(discountedPrices[index])
      return {
        productName: name || null,
        itemA: ogprice,
        itemB: discprice,
        productPrice: {
          discountedPrice: Math.min(ogprice, discprice),
          originalPrice: Math.max(ogprice, discprice)
        },
        productWeight: productWeights[index] || null,
        productImage: productImages[index] || null,
        origin: "swiggy"
      }
    });
  });

  if (products.length === 0) {
    console.warn("No product names found. Verify the selectors or page structure.");
  }

  await browser.close();
  return findCheapestProduct(products, query);
}

module.exports = swiggyScraper;
