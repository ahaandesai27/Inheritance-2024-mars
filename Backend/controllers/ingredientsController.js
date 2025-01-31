const Ingredients = require('../models/Ingredients.js');

const capitalizeWords = (str) => {
    return str
        .split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ');
};

const getIngredients = async (req, res) => {
    const query = req.query.q?.toLowerCase();
    const skip = parseInt(req.query.skip) || 0;
    const limit = parseInt(req.query.limit) || 50;
    
    try {
        const ingredient = await Ingredients.findOne({ "name": query });
        if (ingredient) {
            ingredient.name = capitalizeWords(ingredient.name); // Capitalize the found ingredient's name
            const category = ingredient["category"];
            const other_ingredients = await Ingredients.find({ "category": category }).skip(skip).limit(limit);
            other_ingredients.forEach(item => item.name = capitalizeWords(item.name)); // Capitalize names of other ingredients
            other_ingredients.sort(() => Math.random() - 0.5); // Randomly shuffle
            other_ingredients.unshift(ingredient); // Add the found ingredient first
            res.status(200).json(other_ingredients);
        } else {
            const random_ingredients = await Ingredients.aggregate([{ $sample: { size: limit } }]);
            random_ingredients.forEach(item => item.name = capitalizeWords(item.name)); // Capitalize names of random ingredients
            res.status(200).json(random_ingredients);
        }
    } catch (error) {
        res.status(500).json("An error occured");
    }
};

const getIngredientsByCategory = async (req, res) => {
    const { category } = req.params;
    const skip = parseInt(req.query.skip) || 0;
    const limit = parseInt(req.query.limit) || 50;
    
    try {
        const ingredients = await Ingredients.find({ "category": category }).skip(skip).limit(limit);
        ingredients.forEach(item => item.name = capitalizeWords(item.name)); // Capitalize names of ingredients
        res.status(200).json(ingredients);
    } catch (error) {
        res.status(500).json("An error occured");
    }
}

module.exports = { getIngredients, getIngredientsByCategory };
