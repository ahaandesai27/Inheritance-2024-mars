const puppeteer = require('puppeteer');
const findCheapestProduct = require('./findsmallest.js')

async function bigBasketScraper(query) {
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  // Set a custom User-Agent
  await page.setUserAgent(
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36'
  );

  const startUrl = `https://www.bigbasket.com/ps/?q=${query}&nc=as`;

  console.log(`Navigating to: ${startUrl}`);
  await page.goto(startUrl, { waitUntil: 'networkidle2' });

  // Scroll to load all products
  try {
    await page.evaluate(async () => {
      await new Promise((resolve) => {
        let totalHeight = 0;
        const distance = 300;
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
    console.log("Scrolling complete.");
  } catch (error) {
    console.error("Error during scrolling:", error);
  }

  // Extract product data
  const products = await page.evaluate(() => {
    const mainDivs = Array.from(document.querySelectorAll('.eA-dmzP'));
    return mainDivs.map(div => {
      const name = div.querySelector('.pt-0\\.5.h-full')?.innerText || 'N/A';
      const discountPrice = div.querySelector('.AypOi')?.innerText?.slice(1) || null;
      const originalPrice = div.querySelector('.hsCgvu')?.innerText?.slice(1) || discountPrice;
      const weight = div.querySelector('.cWbtUx')?.innerText.trim() || 'N/A';
      const productLink = div.querySelector('a')?.href || 'N/A';
      return {
        productName: name,
        productPrice: {
          discountedPrice: parseFloat(discountPrice) || null,
          originalPrice: parseFloat(originalPrice) || null,
        },
        productWeight: weight,
        productLink: productLink.startsWith('http') ? productLink : `https://www.bigbasket.com${productLink}`,
        origin: "big basket"
      };
    });
  });

  if (products.length === 0) {
    console.warn("No products found. Verify your selectors or check the page structure.");
  }

  await browser.close();
  return findCheapestProduct(products, query);
}

module.exports = bigBasketScraper;
