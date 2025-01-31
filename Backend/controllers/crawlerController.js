const amazonScraper = require('../crawlers/amazon');
const blinkitScraper = require('../crawlers/blinkit');
const zeptoScraper = require('../crawlers/zepto');
const swiggyScraper = require('../crawlers/swiggy');
const bigBasketScraper = require('../crawlers/bigbasket');
const cache = require('../config/nodeCache');

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
        const cachedData = cache.get(ingredient);
        if (cachedData) {
            return res.json(cachedData)
        }
        const allProducts = await Promise.all([
            amazonScraper(ingredient),
            bigBasketScraper(ingredient),
            zeptoScraper(ingredient),
            swiggyScraper(ingredient)
        ]);
        
        const sortedProducts = allProducts.flat().sort((a, b) => {
            const priceA = a.productPrice.discountedPrice !== null ? a.productPrice.discountedPrice : a.productPrice.originalPrice;
            const priceB = b.productPrice.discountedPrice !== null ? b.productPrice.discountedPrice : b.productPrice.originalPrice;
            return priceA - priceB;
        });

        cache.set(ingredient, sortedProducts);
        return res.json(sortedProducts);
    } catch (error) {
        console.log(error);
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
