const express = require('express');
const router = express.Router();
const { getIngredients } = require('./controller.js');

router.route('/getingredients').get(getIngredients);

module.exports = router;
