const AmazonScraper = require('../scrapers/amazonScraper.js');
const BigBasketScraper = require('../scrapers/bigbasketScraper.js');
const StarquikScraper = require('../scrapers/starquikScraper.js');
const ZeptoScraper = require('../scrapers/zeptoScraper.js');
const { redisClient, connectRedis } = require('../redis');

const scrapers = {
  amazon: AmazonScraper,
  bigbasket: BigBasketScraper,
  zepto: ZeptoScraper,
  starquik: StarquikScraper,
};

function secondsUntilMidnight() {
  const now = new Date();
  const midnight = new Date(
    now.getFullYear(),
    now.getMonth(),
    now.getDate() + 1, // next day
    0, 0, 0, 0
  );
  return Math.floor((midnight - now) / 1000);
}

const cacheTTL = secondsUntilMidnight();

const getIngredients = async (req, res) => {
  try {
    await connectRedis();

    const { q: ingredient, source } = req.query;
    console.log(ingredient, source)

    if (!ingredient) {
      return res.status(400).json({ error: 'Ingredient query parameter "q" is required' });
    }

    if (!source || !scrapers[source.toLowerCase()]) {
      return res.status(400).json({ error: 'Valid source query parameter is required (amazon, blinkit, zepto)' });
    }

    const cacheKey = `ingredients:${source.toLowerCase()}:${ingredient.toLowerCase()}`;
    const cachedData = await redisClient.get(cacheKey);
    if (cachedData) {
      return res.status(200).json(JSON.parse(cachedData));
    }

    const ScraperClass = scrapers[source.toLowerCase()];
    const scraper = new ScraperClass();

    const products = await scraper.scrape(ingredient);

    // Only cache if products is a non-null, non-empty array/object
    const isValid = products && (
      (Array.isArray(products) && products.length > 0) ||
      (typeof products === 'object' && Object.keys(products).length > 0)
    );

    if (isValid) {
      await redisClient.setEx(cacheKey, cacheTTL, JSON.stringify(products));
    }

    return res.json(products);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};


module.exports = { getIngredients };
