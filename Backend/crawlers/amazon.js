const puppeteer = require('puppeteer');
const { URL } = require('url');

async function amazonScraper(query) {
  // Start a headless browser
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  const startUrl = `https://www.amazon.in/s?k=${query}&page=1`;

  await page.goto(startUrl, { waitUntil: 'domcontentloaded' });

  console.log(`Navigating to: ${startUrl}`);

  // const screenshotPath = `screenshots/iphone_screenshot.png`;
  // await page.screenshot({ path: screenshotPath, fullPage: true });
  // console.log(`Screenshot saved at: ${screenshotPath}`);


  // Extract product names and links
  const products = await page.evaluate(() => {
    let productNames = Array.from(document.querySelectorAll('span.a-text-normal')).map(el => el.innerText);
    let productLinks = Array.from(document.querySelectorAll('a.a-link-normal.a-text-normal')).map(el => el.href);
    let productPrices = Array.from(document.querySelectorAll('.a-price-whole')).map(el => el.innerText);
    
    return productNames.map((name, index) => ({
      product_name: name,
      product_link: productLinks[index],
      product_price: productPrices[index] || 'N/A'
    }));
  });

  if (products.length === 0) {
    console.warn("No product names found. Check your selectors.");
  }

  // Output scraped dat

  // Close the browser
  await browser.close();
  return products;
}

module.exports = amazonScraper;