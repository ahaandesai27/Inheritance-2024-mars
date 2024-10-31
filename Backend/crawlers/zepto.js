const puppeteer = require('puppeteer');
const { URL } = require('url');

async function zeptoScraper(query) {
  // Start a headless browser
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  const context = browser.defaultBrowserContext();
  await context.overridePermissions('https://www.zeptonow.com', ['geolocation']);

  await page.setGeolocation({
    latitude: 19.115171,
    longitude: 72.901933
  });

  const startUrl = `https://www.zeptonow.com/search?query=${query}`;
  await page.goto(startUrl, { waitUntil: 'networkidle2' });
  console.log(`Navigating to: ${startUrl}`);

  const products = await page.evaluate(() => {
    const productNames = Array.from(document.querySelectorAll('.\\!tracking-normal')).map(el => el.innerText);
    const productWeights = Array.from(document.querySelectorAll('.\\!font-normal')).map(el => el.innerText);
    const productPrices = Array.from(document.querySelectorAll('.items-end')).map(el => {
      const prices = el.innerText.split('\n\n').map(price => parseInt(price.slice(1)));
      return prices.length > 1 ? { discountedPrice: prices[0], originalPrice: prices[1] } : { originalPrice: prices[0], discountedPrice: null };
    });
    const productImages = Array.from(document.querySelectorAll('.group-hover\\:scale-110')).map(el => el.src);

    return productNames.map((name, index) => ({
      product_name: name,
      product_weight: productWeights[index] || 'N/A',
      product_price: productPrices[index] || { originalPrice: 'N/A', discountedPrice: null },
      product_image: productImages[index] || 'N/A'
    })).sort((a, b) => a.product_price.originalPrice - b.product_price.originalPrice);
  });

  if (products.length === 0) {
    console.warn("No product names found. Check your selectors.");
  }

  await browser.close();
  return products;
}

module.exports = zeptoScraper;
