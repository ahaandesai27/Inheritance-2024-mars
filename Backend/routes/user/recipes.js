const express = require('express');
const router = express.Router();
const { saveRecipe, getSavedRecipes, deleteSavedRecipe } = require('../../controllers/user/recipeControllers.js');

router
    .post('/saved', saveRecipe)
    .delete('/saved', deleteSavedRecipe)
    .get('/saved/:userId', getSavedRecipes);

module.exports = router;