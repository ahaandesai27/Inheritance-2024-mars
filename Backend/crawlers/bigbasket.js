const puppeteer = require('puppeteer');
const { URL } = require('url');

async function bigBasketScraper(query) {
  // Start a headless browser
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  const startUrl = `https://www.bigbasket.com/ps/?q=${query}&nc=as`;

  await page.goto(startUrl, { waitUntil: 'domcontentloaded' });

  console.log(`Navigating to: ${startUrl}`);

  const products = await page.evaluate(() => {
    const mainDivs = Array.from(document.querySelectorAll('.eA-dmzP'));

    return mainDivs.map(div => {
      const name = div.querySelector('.pt-0\\.5.h-full')?.innerText || 'N/A';
      const discountPrice = parseFloat(div.querySelector('.AypOi')?.innerText.slice(1));
      const originalPrice = parseFloat(div.querySelector('.hsCgvu')?.innerText.slice(1)) || discountPrice;
      const weight = div.querySelector('.cWbtUx')?.innerText.trim() || 'N/A';
      const productLink = div.querySelector('a')?.href || 'N/A';
  
      return {
          productName: name,
          productPrice: {
              discountPrice: discountPrice,
              originalPrice: originalPrice
          },
          productWeight: weight,
          productLink: `https://www.bigbasket.com${productLink}`,
          origin: "bigbasket"
      };
  });
  
  });

  if (products.length === 0) {
    console.warn("No product names found. Check your selectors.");
  }

  await browser.close();
  return products;
}

module.exports = bigBasketScraper;