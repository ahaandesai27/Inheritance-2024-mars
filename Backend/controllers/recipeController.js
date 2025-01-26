const Recipe = require('../models/Recipe');
//get all Recipes
const getRecipes = async (req, res) => {
    try {
        const skip = parseInt(req.query.skip) || 0;
        const limit = parseInt(req.query.limit) || 10;
        console.log(skip, limit)
        const cuisine = req.query.cuisine;
        if(cuisine) {
            const recipes = await Recipe.find({Cuisine: cuisine}).skip(skip).limit(limit);
            if (recipes.length === 0) {
                return res.status(204).json({ error: `No recipes found for cuisine ${cuisine}` });
            }
            return res.json(recipes);
        }
        const recipes = await Recipe.find().skip(skip).limit(limit);
        if (recipes.length === 0) {
            return res.status(204).json({ error: 'No recipes found' });
        }
        res.json(recipes);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch recipes' });
        console.log(error)
    }
};

const getRecipeById = async (req, res) => {
    try {
        const recipe  = await Recipe.findOne({_id: req.params.id});
        res.status(200).json(recipe);
    } catch (error) {
        res.status(400).json({ error: 'Failed to find recipe' });
    }
}

const createNewRecipe = async (req, res) => {
    try {
        const recipe = new Recipe(req.body);
        await recipe.save();
        res.status(201).json(recipe);
    }
    catch (error) {
        res.status(400).json({ error: 'Failed to create recipe' });
    }
}

const updateRecipe = async (req, res) => {
    try {
        const recipe  = await Recipe.findOneAndUpdate({_id: req.params.id}, req.body , {new: true, runValidators: true});
        res.status(200).json(recipe);
    } catch (error) {
        res.status(400).json({ error: 'Failed to update recipe' });
    }
}

const deleteRecipe = async (req, res) => {
    try {
        const recipe = await Recipe.findOneAndDelete({_id: req.params.id});
        res.status(200).json(recipe);
    } catch (error) {
        res.status(400).json({ error: 'Failed to delete recipe' });
    }
}


module.exports = {
    getRecipes,
    getRecipeById,
    createNewRecipe,
    updateRecipe,
    deleteRecipe,
}