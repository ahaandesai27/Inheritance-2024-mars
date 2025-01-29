const express = require('express');
const router = express.Router();
const ingredientsController = require('../../controllers/ingredientsController');

const {
    getIngredients
} = ingredientsController;

router.get('/', getIngredients);

module.exports = router;