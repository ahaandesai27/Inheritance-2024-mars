const BaseScraper = require('./baseScraper');
// Amazon Scraper
class AmazonScraper extends BaseScraper {
    constructor(config) {
        super(config);
        this.url = 'https://www.amazon.in';
        this.baseUrl = 'https://www.amazon.in/s?k=';
        this.origin = 'amazon';
        this.needsScrolling = false;
        this.selectors = {
            name: '.a-color-base.a-text-normal',
            discountedPrice: '.a-price-whole',
            originalPrice: '.aok-inline-block .a-text-price span',
            weight: '.a-price+ .a-color-secondary',
            image: 'img.s-image',
            link: '.a-color-base.a-text-normal',
            priceSliceStart: 1
        };
    }

    buildSearchUrl(query) {
        return `${this.baseUrl}${encodeURIComponent(query)}&page=1`;
    }
}

module.exports = AmazonScraper