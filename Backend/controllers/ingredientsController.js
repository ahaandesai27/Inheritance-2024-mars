const Ingredients = require('../models/Ingredients.js');

const getIngredients = async (req, res) => {
    const category = req.query.q;
    const skip = parseInt(req.query.skip) || 0;
    const limit = parseInt(req.query.limit) || 50;
    
    try {
        const ingredients = await Ingredients.find({category}).skip(skip).limit(limit);
        res.json(ingredients)
    }
    catch (error) {
        res.status(500).json(error.message);
    }
}

module.exports = { getIngredients }