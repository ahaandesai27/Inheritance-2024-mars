const mongoose = require('mongoose');

const recipeSchema = new mongoose.Schema({
  TranslatedRecipeName: { type: String, required: true },
  TranslatedIngredients: { type: String, required: true },
  TotalTimeInMins: { type: Number, required: true, min: [1, 'Total time must be greater than 0'] },
  Cuisine: { type: String, required: true },
  TranslatedInstructions: { type: String, required: true },
  URL: { type: String },
  "Cleaned-Ingredients": { type: String, required: true },
  "image-url": { type: String, required: true },
  "Ingredient-count": { type: Number, required: true, min: [1, 'Ingredient count must be greater than 0'] },
  calorieCount: { type: Number, required: true, min: [1, 'Calorie count must be greater than 0'] }
});

const Recipe = mongoose.model('recipes', recipeSchema);

module.exports = Recipe;
