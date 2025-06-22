const puppeteer = require('puppeteer-core');

function findCheapestProduct(products, query) {
  return products.reduce((minProduct, currentProduct) => {
    if (!currentProduct.productName || currentProduct.productPrice.originalPrice === null || 
        !currentProduct.productName?.toLowerCase().includes(query.toLowerCase())) {
      return minProduct;
    }
    return currentProduct.productPrice.originalPrice < minProduct.productPrice.originalPrice
      ? currentProduct
      : minProduct;
  }, { productPrice: { originalPrice: Infinity } });  
}

// Base Scraper Class
class BaseScraper {
    constructor(config = {}) {
        this.config = {
            scrapeLimit: config.scrapeLimit || 8,
            executablePath: config.executablePath || '/usr/bin/google-chrome',
            //executablePath: config.executablePath || process.env.PUPPETEER_EXECUTABLE_PATH || '/usr/bin/chromium-browser', - for alpine linux docker build
            headless: true,
            timeout: config.timeout || 60000,
            userAgents: config.userAgents || [
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0',
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15'
            ],
            ...config
        };
        this.url = '';
        this.baseUrl = '';
        this.selectors = {};
        this.origin = '';
        this.needsScrolling = false;
        this.viewport = { width: 1280, height: 720 };

        // Actual puppeteer object
        this.page = null;
    }

    async getRandomUserAgent() {
        return this.config.userAgents[Math.floor(Math.random() * this.config.userAgents.length)];
    }

    buildSearchUrl(query) {
        // The actual URL to be scraped for each query 
        return `${this.baseUrl}${encodeURIComponent(query)}`;
    }

    async setupPage() {
        // Set user agent
        const userAgent = await this.getRandomUserAgent();
        console.log(`Using user agent: ${userAgent}`);
        await this.page.setUserAgent(userAgent);

        // Set viewport - larger viewports mean more items in the same screen without scrolling
        await this.page.setViewport(this.viewport);

        if (this.needsGeolocation) {
            // some pages like zepto need location enabled before scraping products
            const context = this.page.browser().defaultBrowserContext();
            await context.overridePermissions(this.url, ['geolocation']);
            await this.page.setGeolocation(this.geolocation);
        }
    }

    async scrollToLoadProducts() {
        if (!this.needsScrolling) return;
        try {
            await this.page.evaluate(async () => {
                await new Promise((resolve) => {
                    let totalHeight = 0;
                    const distance = 200;
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
    }

    async infiniteScrollToLimit() {
        let products = [];
        let hasMoreProducts = true;
        while (products.length < this.config.scrapeLimit && hasMoreProducts) {
            const newProducts = await this.extractProducts();
            products = [...products, ...newProducts];
            if (products.length < this.config.scrapeLimit) {
                const previousHeight = await this.page.evaluate('document.body.scrollHeight');
                await this.page.evaluate('window.scrollTo(0, document.body.scrollHeight)');
                try {
                    await this.page.waitForFunction(`document.body.scrollHeight > ${previousHeight}`, { timeout: 5000 });
                    await new Promise(resolve => setTimeout(resolve, 1000));
                } catch (error) {
                    console.log("No more content to load or timeout reached");
                    hasMoreProducts = false;
                }
            } else {
                hasMoreProducts = false;
            }
        }
        return products.slice(0, this.config.scrapeLimit);
    }

    async extractProducts() {
        return await this.page.evaluate(
        (sel, orig) => {
            const names = Array.from(document.querySelectorAll(sel.name))
                               .map(el => el.innerText);

            const discountedPrices = Array.from(document.querySelectorAll(sel.discountedPrice))
                                          .map(el => parseInt(el.innerText.replace(/,/g, ''), 10));
                                          // some formatting to be able to convert to int
                
            const originalPrices = Array.from(document.querySelectorAll(sel.originalPrice))
                                        .map(el => parseInt(el.innerText.slice(1), 10));
                                        // take out rupee symbol    

            const weights = Array.from(document.querySelectorAll(sel.weight))
                                 .map(el => el.innerText);

            const images = Array.from(document.querySelectorAll(sel.image))
                                .map(el => el.src);
                                // returns src tag of img selector
            
            const links = Array.from(document.querySelectorAll(sel.link))
                               .map(el => el.closest('a')?.href || null);
                               // returns closest a href tag to selector

            // building final object to return
            return names.map((name, index) => ({
                productName: name,
                productPrice: {
                    discountedPrice: discountedPrices[index] || originalPrices[index],
                    originalPrice: originalPrices[index] || null
                },
                productWeight: weights[index],
                productImage: images[index],
                productLink: links[index],
                origin: orig
            })).filter(product => 
                product.productPrice.discountedPrice <= product.productPrice.originalPrice
            );      // only have products whose discountedPrice is lesser than original -> in some cases the selectors were giving wrong values
        }, 
        this.selectors, this.origin);
    }

    async scrape(query) {
        let browser;
        try {
            browser = await puppeteer.launch({
                executablePath: this.config.executablePath,
                args: [
                    '--no-sandbox',
                    '--disable-popup-blocking',
                    '--disable-notifications',
                    '--disable-setuid-sandbox',
                    '--use-fake-ui-for-media-stream'
                ],
                headless: true
            });

            this.page = await browser.newPage();
            await this.setupPage();

            // Set geolocation permissions and location before entering page 
            if (this.needsGeolocation && this.geolocation) {
                const context = browser.defaultBrowserContext();
                await context.overridePermissions(this.url, ['geolocation']);
                await this.page.setGeolocation(this.geolocation);
            }

            const searchUrl = this.buildSearchUrl(query);
            console.log(`Navigating to: ${searchUrl}`);

            await this.page.goto(searchUrl, { 
                waitUntil: this.needsScrolling ? 'networkidle2' : 'domcontentloaded',
                timeout: this.config.timeout 
            });

            // Wait for products to load
            if (this.selectors.name) {
                try {
                    await this.page.waitForSelector(this.selectors.name, { timeout: this.config.timeout });
                } catch (error) {
                    console.warn(`Products did not load in time for ${this.origin}`);
                    return null;
                }
            }

            let products;
            if (this.needsInfiniteScroll) {
                products = await this.infiniteScrollToLimit();
            } else {
                await this.scrollToLoadProducts();
                products = await this.extractProducts();
            }

            // Cutoff after 30 products
            const maxProducts = 30;
            if (products.length > maxProducts) {
                products = products.slice(0, maxProducts);
            }

            if (products.length === 0) {
                console.warn(`No products found for ${this.origin}. Check selectors.`);
                return null;
            }

            console.log(`Scraped ${products.length} products from ${this.origin}`);
            return findCheapestProduct(products, query);

        } catch (error) {
            console.error(`Error occurred during ${this.origin} scraping:`, error);
            return null;
        } finally {
            if (browser) {
                await browser.close();
            }
            this.page = null;
        }
    }
}

module.exports = BaseScraper
