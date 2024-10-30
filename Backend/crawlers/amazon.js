const puppeteer = require('puppeteer');
const { URL } = require('url');

async function amazonScraper(query) {
  // Start a headless browser
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  const startUrl = `https://www.amazon.in/s?k=${query}&page=1`;

  await page.goto(startUrl, { waitUntil: 'domcontentloaded' });

  console.log(`Navigating to: ${startUrl}`);

  const products = await page.evaluate(() => {
    const productNames = Array.from(document.querySelectorAll('span.a-text-normal')).map(el => el.innerText);
    const productLinks = Array.from(document.querySelectorAll('a.a-link-normal.a-text-normal')).map(el => el.href);
    const productPrices = Array.from(document.querySelectorAll('.a-price-whole')).map(el => el.innerText);
    const productImages = Array.from(document.querySelectorAll('img.s-image')).map(el => el.src);
    const productWeights = Array.from(document.querySelectorAll('.a-price+ .a-color-secondary')).map(el => el.innerText);
    // Need to format later
    return productNames.map((name, index) => ({
      product_name: name,
      product_link: productLinks[index],
      product_price: productPrices[index] || 'N/A',
      productImages: productImages[index],
      productWeights: productWeights[index]
    }));
  });

  if (products.length === 0) {
    console.warn("No product names found. Check your selectors.");
  }

  await browser.close();
  return products;
}

module.exports = amazonScraper;