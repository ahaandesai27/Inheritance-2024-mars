const amazonScraper = require('../crawlers/amazon');
const blinkitScraper = require('../crawlers/blinkit');
const zeptoScraper = require('../crawlers/zepto');
const swiggyScraper = require('../crawlers/swiggy');
const bigBasketScraper = require('../crawlers/bigbasket');

const getAmazonIngredients = async (req, res) => {
    try {
        const ingredient = req.query.q;
        const products = await amazonScraper(ingredient);
        return res.json(products);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch ingredients' });
    }
}

const getBlinkitIngredients = async (req, res) => {
    try {
        const ingredient = req.query.q;
        const products = await blinkitScraper(ingredient);
        return res.json(products);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch ingredients' });
    }
}

const getZeptoIngredients = async (req, res) => {
    try {
        const ingredient = req.query.q;
        const products = await zeptoScraper(ingredient);
        return res.json(products);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch ingredients' });
    }
}

const getSwiggyIngredients = async (req, res) => {
    try {
        const ingredient = req.query.q;
        const products = await swiggyScraper(ingredient);
        return res.json(products);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch ingredients' });
    }
}

const getBigBasketIngredients = async (req, res) => {
    try {
        const ingredient = req.query.q;
        const products = await bigBasketScraper(ingredient);
        return res.json(products);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch ingredients' });
    }
}

const getAllIngredients = async (req, res) => {
    try {
        const ingredient = req.query.q;
        const [amazonProducts, bigBasketProducts, zeptoProducts, swiggyProducts] = await Promise.all([
            amazonScraper(ingredient),
            bigBasketScraper(ingredient),
            zeptoScraper(ingredient),
            swiggyScraper(ingredient)
        ]);

        const allProducts = [...amazonProducts, ...bigBasketProducts, ...zeptoProducts, ...swiggyProducts];

        allProducts.sort((a, b) => {
            if (a.discountedPrice === b.discountedPrice) {
                return a.originalPrice - b.originalPrice;
            }
            return a.discountedPrice - b.discountedPrice;
        });

        return res.json(allProducts);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch ingredients' });
    }
}

module.exports = {
    getAmazonIngredients,
    getBlinkitIngredients,
    getZeptoIngredients,
    getSwiggyIngredients,
    getBigBasketIngredients,
    getAllIngredients
}
