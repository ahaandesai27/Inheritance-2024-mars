// BigBasket Scraper
const BaseScraper = require('./baseScraper');

class BigBasketScraper extends BaseScraper {
    constructor(config) {
        super(config);
        this.url = 'https://www.bigbasket.com';
        this.baseUrl = 'https://www.bigbasket.com/ps/?q=';
        this.origin = 'big basket';
        this.needsScrolling = false;
        this.selectors = {
            name: '.pt-0\\.5.h-full',
            discountedPrice: '.AypOi',
            originalPrice: '.hsCgvu',
            weight: '.cWbtUx',
            link: 'img.cSWRCd',             // not working, not able to find a proper selector
            priceSliceStart: 1
        };
    }

    buildSearchUrl(query) {
        return `${this.baseUrl}${encodeURIComponent(query)}&nc=as`;
    }
}

module.exports = BigBasketScraper

    // async extractProducts() {
    //     return await this.page.evaluate((sel, orig) => {
    //         const mainDivs = Array.from(document.querySelectorAll('.eA-dmzP'));
    //         return mainDivs.map(div => {
    //             const name = div.querySelector(sel.name)?.innerText || 'N/A';
    //             const discountPrice = div.querySelector(sel.discountedPrice)?.innerText?.slice(1) || null;
    //             const originalPrice = div.querySelector(sel.originalPrice)?.innerText?.slice(1) || discountPrice;
    //             const weight = div.querySelector(sel.weight)?.innerText.trim() || 'N/A';
    //             const productLink = div.querySelector(sel.link)?.href || 'N/A';

    //             return {
    //                 productName: name,
    //                 productPrice: {
    //                     discountedPrice: parseFloat(discountPrice) || null,
    //                     originalPrice: parseFloat(originalPrice) || null
    //                 },
    //                 productWeight: weight,
    //                 productLink: productLink.startsWith('http') ? productLink : 
    //                             `https://www.bigbasket.com${productLink}`,
    //                 origin: orig
    //             };
    //         });
    //     }, this.selectors, this.origin);
    // }