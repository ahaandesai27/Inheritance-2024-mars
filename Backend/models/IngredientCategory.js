const mongoose = require('mongoose');

const IngredientSchema = new mongoose.Schema({
  name: String,
  nutritionalInfo: {
    calories: Number,
    protein: Number,
    fat: Number,
    carbohydrates: Number
  },
});

const SubcategorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  ingredients: [IngredientSchema]
});

const CategorySchema = new mongoose.Schema({
  category: {
    type: String,
    required: true,
    unique: true
  },
  subcategories: [SubcategorySchema]
});

const Category = mongoose.model('Ingredients', CategorySchema);
module.exports = Category;
