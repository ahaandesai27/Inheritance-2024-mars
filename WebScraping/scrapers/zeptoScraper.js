const BaseScraper = require('./baseScraper');

class ZeptoScraper extends BaseScraper {
    constructor(config) {
        super(config);
        this.url = 'https://www.zeptonow.com';
        this.baseUrl = 'https://www.zeptonow.com/search?query=';
        this.origin = 'zepto';
        this.needsScrolling = false;
        this.needsGeolocation = true;
        this.geolocation = {
            latitude: config?.geolocation?.latitude || 19.115171,
            longitude: config?.geolocation?.longitude || 72.901933
        };
        this.selectors = {
            name: '.\\!tracking-normal',
            weight: '.\\!font-normal',
            discountedPrice: '.font-heading.text-lg.tracking-wide.line-clamp-1.\\!font-semibold.\\!text-md.\\!leading-4.\\!m-0.mb-0\\.5.py-0\\.5',
            originalPrice: '.font-body.text-xs.line-clamp-1.\\!text-3xs.text-skin-primary-void\\/40.line-through.sm\\:\\!text-2xs.\\!mb-\\[0\\.175rem\\].sm\\:\\!mb-\\[0\\.2rem\\]',
            image: '.group-hover\\:scale-110',
            link: 'a[class="!my-0 relative my-3 mb-9 rounded-t-xl rounded-b-md group selectorgadget_suggested"][data-testid="product-card"]'
        };
    }
}

module.exports = ZeptoScraper


    // async extractProducts() {
    //     return await this.page.evaluate((sel, orig) => {
    //         const names = Array.from(document.querySelectorAll(sel.name))
    //                            .map(el => el.innerText);

    //         const weights = Array.from(document.querySelectorAll(sel.weight))
    //                              .map(el => el.innerText);
            
    //         const productImages = Array.from(document.querySelectorAll(sel.image))
    //                                    .map(el => el.src);

    //         const productLinks = Array.from(document.querySelectorAll(sel.link))
    //                                   .map(el => el.innerHTML);

    //         const productPrices = Array.from(document.querySelectorAll(sel.price)).map(el => {
    //             const prices = el.innerText.split('\n\n').map(price => parseInt(price.slice(1)));
    //             return prices.length > 1 ? {
    //                 discountedPrice: prices[0],
    //                 originalPrice: prices[1]
    //             } : {
    //                 originalPrice: prices[0],
    //                 discountedPrice: null
    //             };
    //         });


    //         return names.map((name, index) => ({
    //             productName: name,
    //             productPrice: productPrices[index] || {
    //                 originalPrice: null,
    //                 discountedPrice: null
    //             },
    //             productWeight: weights[index] || null,
    //             productImage: productImages[index] || null,
    //             productLink: productLinks[index] || null,
    //             origin: orig
    //         })).sort((a, b) => (a.productPrice.originalPrice || 0) - (b.productPrice.originalPrice || 0));
    //     }, this.selectors, this.origin);
    // }