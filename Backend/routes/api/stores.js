const express = require('express');
const router = express.Router();
const storesController = require('../../controllers/storesController');

const {
    getStores,
    searchStores,
    getCheapest,
    searchStore
} = storesController;

// the literal paths have to be declared before /:store, or they get swallowed by it
router.get('/', getStores);
router.get('/search', searchStores);
router.get('/cheapest', getCheapest);
router.get('/:store', searchStore);

module.exports = router;
