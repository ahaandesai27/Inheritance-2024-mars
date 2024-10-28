const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch({ headless: false });
    const page = await browser.newPage();

    // Enable geolocation for your current location
    const context = browser.defaultBrowserContext();
    await context.overridePermissions('https://www.zeptonow.com', ['geolocation']);
    
    // Set your current location (latitude and longitude)
    await page.setGeolocation({
        latitude: 19.115171,
        longitude: 72.901933
    });
    
    await page.goto('https://www.zeptonow.com/search?query=almonds', { waitUntil: 'networkidle2' });
    await page.setViewport({ width: 1920, height: 1080 });
    // Uncomment if you need to handle the location popup
    // await page.waitForSelector('[data-testid="location-popup"]');
    // await page.click('[data-testid="auto-address-btn"]');
    // await page.waitForTimeout(2000);
    const selector = '.\\!tracking-normal';

    // Scrape the specified elements with corrected selector
    const scrapedData = await page.$$eval(selector, elements => 
        elements.map(element => element.innerText)
    );

    console.log(scrapedData);

    await browser.close();
})();
