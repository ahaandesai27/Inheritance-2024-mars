const puppeteer = require('puppeteer-core');
const findCheapestProduct = require('./findsmallest.js');
const { URL } = require('url');

async function amazonScraper(query) {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    headless: true
  });
  const page = await browser.newPage();

  const startUrl = `https://www.amazon.in/s?k=${query}&page=1`;

  await page.goto(startUrl, { waitUntil: 'domcontentloaded' });

  console.log(`Navigating to: ${startUrl}`);

  const products = await page.evaluate(() => {
    const productNames = Array.from(document.querySelectorAll('.a-color-base.a-text-normal')).map(el => el.innerText);
    const productPrices = Array.from(document.querySelectorAll('.a-price-whole')).map(el => parseInt(el.innerText.replace(/,/g, ''), 10));
    const productMRPs = Array.from(document.querySelectorAll('.aok-inline-block .a-text-price span')).map(el => parseInt(el.innerText.slice(1), 10));
    const productWeights = Array.from(document.querySelectorAll('.a-price+ .a-color-secondary')).map((el) => {
      el = el.innerText
      let result = el.split('\n')[2].replace(')', '');
      return result;
    });
    const productImages = Array.from(document.querySelectorAll('img.s-image')).map(el => el.src);
    const productLinks = Array.from(document.querySelectorAll('.a-color-base.a-text-normal')).map(el => el.closest('a').href);

    return productNames.map((name, index) => ({
      productName: name,
      productPrice: {
        discountedPrice: productPrices[index] || productMRPs[index],
        originalPrice: productMRPs[index] || null,
      },
      productWeight: productWeights[index],
      productImage: productImages[index],
      productLink: productLinks[index] || null,
      origin: "amazon"
    }));
  });

  const filteredProducts = products.filter(product => product.productPrice.discountedPrice <= product.productPrice.originalPrice);

  if (filteredProducts.length === 0) {
    console.warn("No valid products found. Check your selectors or filter criteria.");
  }

  await browser.close();
  return findCheapestProduct(filteredProducts, query);
}

module.exports = amazonScraper;
