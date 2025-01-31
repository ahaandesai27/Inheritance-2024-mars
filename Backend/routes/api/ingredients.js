const express = require('express');
const router = express.Router();
const ingredientsController = require('../../controllers/ingredientsController');

const {
    getIngredients,
    getIngredientsByCategory
} = ingredientsController;

router.get('/:category', getIngredientsByCategory);
router.get('/', getIngredients);

module.exports = router;