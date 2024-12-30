const DietPlan = require('../models/DietPlan');
const Recipe = require('../models/Recipe');
const User = require('../models/User');

const addRecipeToDietPlan = async (req, res) => {
    const { dietPlanId, recipeId } = req.params;
    try {
        const dietPlan = await DietPlan.findById(dietPlanId);
        if (!dietPlan) {
            return res.status(404).json({ message: 'Diet Plan not found' });
        }

        const recipe = await Recipe.findById(recipeId);
        if (!recipe) {
            return res.status(404).json({ message: 'Recipe not found' });
        }
        dietPlan.totalCalorieCount += recipe.calorieCount;
        dietPlan.recipes.push(recipeId);
        await dietPlan.save();

        res.status(200).json({ message: 'Recipe added to diet plan successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

const getAllRecipesInDietPlan = async (req, res) => {
    const { dietPlanId } = req.params;
    try {
        const dietPlan = await DietPlan.findById(dietPlanId).populate('recipes');
        if (!dietPlan) {
            return res.status(404).json({ message: 'Diet Plan not found' });
        }

        res.status(200).json(dietPlan.recipes);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

const deleteRecipeFromDietPlan = async (req, res) => {
    const { dietPlanId, recipeId } = req.params;
    try {
        const dietPlan = await DietPlan.findById(dietPlanId);
        if (!dietPlan) {
            return res.status(404).json({ message: 'Diet Plan not found' });
        }

        const recipeIndex = dietPlan.recipes.indexOf(recipeId);
        if (recipeIndex === -1) {
            return res.status(404).json({ message: 'Recipe not found in diet plan' });
        }
        
        dietPlan.totalCalorieCount -= dietPlan.recipes[recipeIndex].calorieCount;
        dietPlan.recipes.splice(recipeIndex, 1);
        await dietPlan.save();

        res.status(200).json({ message: 'Recipe removed from diet plan successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

module.exports = {
    addRecipeToDietPlan,
    getAllRecipesInDietPlan,
    deleteRecipeFromDietPlan
};