const Recipe = require('../../models/Recipe.js');
const User = require('../../models/User.js');

const getSavedRecipes = async (req, res) => {
    const { userId } = req.params;
    try {
        const user = await User.findById(userId).populate('savedRecipes');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.status(200).json(user.savedRecipes);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
}

const deleteSavedRecipe = async (req, res) => {
    const { recipeId, userId } = req.body;
    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const recipeIndex = user.savedRecipes.indexOf(recipeId);
        if (recipeIndex === -1) {
            return res.status(404).json({ message: 'Recipe not found in saved recipes' });
        }

        user.savedRecipes.splice(recipeIndex, 1);
        await user.save();

        res.status(200).json({ message: 'Recipe removed from saved recipes successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
}

const saveRecipe = async (req, res) => {
    const { recipeId, userId } = req.body;
    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const recipe = await Recipe.findById(recipeId);
        if (!recipe) {
            return res.status(404).json({ message: 'Recipe not found' });
        }

        user.savedRecipes.push(recipeId);
        await user.save();

        res.status(200).json({ message: 'Recipe saved successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

module.exports = {
    getSavedRecipes,
    saveRecipe,
    deleteSavedRecipe
}