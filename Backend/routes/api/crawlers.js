const express = require('express');
const router = express.Router();
const crawlerController = require('../../controllers/crawlerController');

// const ROLES_LIST = require('../../config/roles_list');
// const verifyRoles = require('../../middleware/verifyRoles');

const {
    getAmazonIngredients,
    getBlinkitIngredients,
    getZeptoIngredients
} = crawlerController;

router.route('/amazon').get(getAmazonIngredients);
router.route('/blinkit').get(getBlinkitIngredients);
router.route('/zepto').get(getZeptoIngredients);

module.exports = router;