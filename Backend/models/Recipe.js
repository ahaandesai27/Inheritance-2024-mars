const mongoose = require('mongoose');

const recipeSchema = new mongoose.Schema({
  translatedRecipeName: { type: String, required: true },
  translatedIngredients: { type: String, required: true },
  totalTimeInMins: { type: Number, required: true },
  cuisine: { type: String, required: true },
  translatedInstructions: { type: String, required: true },
  url: { type: String },
  cleanedIngredients: { type: String, required: true },
  imageUrl: { type: String, required: true },
  ingredientCount: { type: Number, required: true }
});

const Recipe = mongoose.model('recipes', recipeSchema);

module.exports = Recipe;
