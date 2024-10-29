const puppeteer = require('puppeteer');

async function zeptoScraper(query) {
    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();

    // Enable geolocation for your current location
    const context = browser.defaultBrowserContext();
    await context.overridePermissions('https://www.zeptonow.com', ['geolocation']);
    
    // Set your current location (latitude and longitude)
    await page.setGeolocation({
        latitude: 19.115171,
        longitude: 72.901933
    });

    // Go to the page with the specified query
    await page.goto(`https://www.zeptonow.com/search?query=${query}`, { waitUntil: 'networkidle2' });
    await page.setViewport({ width: 1920, height: 1080 });

    // Optional: Handle location popup if needed
    // await page.waitForSelector('[data-testid="location-popup"]');
    // await page.click('[data-testid="auto-address-btn"]');
    // await page.waitForTimeout(2000);

    const selector = '.\\!tracking-normal';

    // Scrape the specified elements
    const scrapedData = await page.$$eval(selector, elements => 
        elements.map(element => element.innerText)
    );

    await browser.close();
    return scrapedData;
}

module.exports = zeptoScraper;