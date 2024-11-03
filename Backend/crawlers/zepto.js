const puppeteer = require('puppeteer');
const {
  URL
} = require('url');
// https://www.zeptonow.com/search?query=almonds - for testing

async function zeptoScraper(query) {
  try {
    // Start a headless browser
    const browser = await puppeteer.launch({
      headless: true
    });
    const page = await browser.newPage();

    const context = browser.defaultBrowserContext();
    await context.overridePermissions('https://www.zeptonow.com', ['geolocation']);

    await page.setGeolocation({
      latitude: 19.115171,
      longitude: 72.901933
    });

    const startUrl = `https://www.zeptonow.com/search?query=${query}`;
    await page.goto(startUrl, {
      waitUntil: 'networkidle2'
    });
    console.log(`Navigating to: ${startUrl}`);

    const products = await page.evaluate(() => {
      const productNames = Array.from(document.querySelectorAll('.\\!tracking-normal')).map(el => el.innerText);
      const productWeights = Array.from(document.querySelectorAll('.\\!font-normal')).map(el => el.innerText);
      const productPrices = Array.from(document.querySelectorAll('.items-end')).map(el => {
        const prices = el.innerText.split('\n\n').map(price => parseInt(price.slice(1)));
        return prices.length > 1 ? {
          discountedPrice: prices[0],
          originalPrice: prices[1]
        } : {
          originalPrice: prices[0],
          discountedPrice: null
        };
      });
      const productImages = Array.from(document.querySelectorAll('.group-hover\\:scale-110')).map(el => el.src);
      const productLinks = Array.from(document.querySelectorAll('a.\\!my-0.relative.my-3.mb-9.rounded-t-xl.rounded-b-md.group')).map(el => el.href);

      return productNames.map((name, index) => ({
        productName: name,
        productPrice: productPrices[index] || {
          originalPrice: 'N/A',
          discountedPrice: null
        },
        productWeight: productWeights[index] || 'N/A',
        productImage: productImages[index] || 'N/A',
        productLink: productLinks[index] || 'No-link',
        origin: "zepto"
      })).sort((a, b) => a.productPrice.originalPrice - b.productPrice.originalPrice);
    });

    if (products.length === 0) {
      console.warn("No product names found. Check your selectors.");
    }

    await browser.close();
    return products;
  } catch (error) {
    console.log(error);
  }
}

module.exports = zeptoScraper;