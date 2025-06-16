const puppeteer = require('puppeteer-core');
const express = require('express');
const findCheapestProduct = require('./findsmallest');
const fs = require('fs').promises;

const app = express();

const SCRAPE_LIMIT = 8;
const userAgents = [
    'Mozilla/5.0 (Linux; Android 10; SM-G960F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Mobile Safari/537.36'
];

async function getRandomUserAgent() {
    return userAgents[Math.floor(Math.random() * userAgents.length)];
}

async function blinkitScraper(query) {
    let browser;
    try {
        const browser = await puppeteer.launch({
            executablePath: '/usr/bin/google-chrome',
            args: ['--no-sandbox', '--disable-setuid-sandbox'],
            headless: true
          });
        const page = await browser.newPage();

        // Set up to capture console logs
        page.on('console', msg => {
            for (let i = 0; i < msg.args().length; ++i)
                console.log(`${i}: ${msg.args()[i]}`);
        });

        const start_url = `https://blinkit.com/s/?q=${query}`;
        console.log(start_url);

        const userAgent = await getRandomUserAgent();
        console.log(`Using user agent: ${userAgent}`);

        await page.setUserAgent(userAgent);
        await page.setViewport({ width: 777, height: 689 });

        await page.goto(start_url, { waitUntil: 'networkidle2', timeout: 60000 });
        await page.waitForSelector('.tw-font-semibold.tw-line-clamp-2', { timeout: 60000 });

        let products = [];
        let hasMoreProducts = true;

        while (products.length < SCRAPE_LIMIT && hasMoreProducts) {
            let newProducts = await page.evaluate(() => {
                let product_names = Array.from(document.querySelectorAll('.tw-font-semibold.tw-line-clamp-2')).map(el => el.innerText);
                let product_weights = Array.from(document.querySelectorAll('.ljxcbQ div div')).map(el => el.innerText);
                let product_images = Array.from(document.querySelectorAll('.gagoLZ img')).map(el => el.src).slice(6)
                let productDiscountedPrices = Array.from(document.querySelectorAll('div.tw-text-200.tw-font-semibold')).map(el => el.innerText.slice(1));
                let productOriginalPrices = Array.from(document.querySelectorAll('div.tw-text-200.tw-font-regular.tw-line-through span span')).map(el => el.innerText.slice(1));

                return product_names.map((name, index) => ({
                    productName: name,
                    productPrice: {
                        discountedPrice: productDiscountedPrices[index] || 'N/A',
                        originalPrice: productOriginalPrices[index] || 'N/A'
                    },
                    productWeight: product_weights[index] || 'N/A',
                    productImage: product_images[index],
                    productLink: null,
                    origin: "blinkit"
                }));
            });

            products = [...products, ...newProducts];

            if (products.length < SCRAPE_LIMIT) {
                let previousHeight = await page.evaluate('document.body.scrollHeight');
                await page.evaluate('window.scrollTo(0, document.body.scrollHeight)');
                await page.waitForFunction(`document.body.scrollHeight > ${previousHeight}`);
                await new Promise((resolve) => setTimeout(resolve, 1000));
            } else {
                hasMoreProducts = false;
            }
        }

        products = products.slice(0, SCRAPE_LIMIT);

        if (products.length === 0) {
            console.warn("No product names found. Check your selectors.");
            return null;
        }
        console.log(`Scraped ${products.length} products`);
        const cheapestProduct = products.reduce((minProduct, currentProduct) => {
            return currentProduct.productPrice.originalPrice < minProduct.productPrice.originalPrice ? currentProduct : minProduct;
          });
        return findCheapestProduct(products, query);

    } catch (error) {
        console.error("Error occurred during scraping:", error);
    } finally {
        if (browser) {
            await browser.close();
        }
    }
}

module.exports = blinkitScraper;
