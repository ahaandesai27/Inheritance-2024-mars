const Ingredients = require('../models/Ingredients.js');

const getIngredients = async (req, res) => {
    const query = req.query.q.toLowerCase();
    const skip = parseInt(req.query.skip) || 0;
    const limit = parseInt(req.query.limit) || 50;
    
    try {
        const ingredient = await Ingredients.findOne({"name": query});
        if (ingredient) {
            const category = ingredient["category"]
            const other_ingredients = await Ingredients.find({"category": category}).skip(skip).limit(limit);
            res.status(200).json(other_ingredients);
        }
        else {
            const random_ingredients = await Ingredients.aggregate([{ $sample: { size: limit } }])
            // if not found, just return a random set of ingredients
            res.status(200).json(random_ingredients);
        }
    }
    catch (error) {
        res.status(500).json("An error occured");
    }
}

module.exports = { getIngredients }