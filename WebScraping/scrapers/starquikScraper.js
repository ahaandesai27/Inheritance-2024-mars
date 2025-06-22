const BaseScraper = require('./baseScraper');
// Amazon Scraper
class StarquikScraper extends BaseScraper {
    constructor(config) {
        super(config);
        this.baseUrl = 'https://www.starquik.com/search/';
        this.origin = 'starquik';
        this.needsScrolling = false;       
        //tradeoff - less products, more performance
        this.selectors = {
            name: '.product-card-name-container a',
            originalPrice: '.product-card-cancelled-price',
            discountedPrice: '.product-card-price-container-price',
            weight: '.two-line-ellipsis',
            image: '.product-image-container',
            link: '.product-card-name-container a',
            priceSliceStart: 1
        };
    }

    buildSearchUrl(query) {
        return `${this.baseUrl}${encodeURIComponent(query)}&page=1`;
    }
}

module.exports = StarquikScraper

    // async extractProducts() {
    //     return await this.page.evaluate((sel, orig) => {
    //         const names = Array.from(document.querySelectorAll(sel.name)).map(el => el.innerText);
    //         const discountedPrices = Array.from(document.querySelectorAll(sel.discountedPrice))
    //             .map(el => parseInt(el.innerText.replace(/,/g, ''), 10));
    //         const originalPrices = Array.from(document.querySelectorAll(sel.originalPrice))
    //             .map(el => parseInt(el.innerText.slice(1), 10));
    //         const weights = Array.from(document.querySelectorAll(sel.weight)).map(el => {
    //             const text = el.innerText;
    //             const lines = text.split('\n');
    //             return lines[2] ? lines[2].replace(')', '') : 'N/A';
    //         });
    //         const images = Array.from(document.querySelectorAll(sel.image)).map(el => el.src);
    //         const links = Array.from(document.querySelectorAll(sel.link))
    //             .map(el => el.closest('a')?.href || null);

    //         return names.map((name, index) => ({
    //             productName: name,
    //             productPrice: {
    //                 discountedPrice: discountedPrices[index] || originalPrices[index],
    //                 originalPrice: originalPrices[index] || null
    //             },
    //             productWeight: weights[index],
    //             productImage: images[index],
    //             productLink: links[index],
    //             origin: orig
    //         })).filter(product => 
    //             product.productPrice.discountedPrice <= product.productPrice.originalPrice
    //         );
    //     }, this.selectors, this.origin);
    // }