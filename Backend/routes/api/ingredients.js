// Define routes with the created functions
const express = require('express');
const router = express.Router();
const ingredientsController = require('../../controllers/ingredientsController');

const {
    createCategory,
    getAllCategories,
    getCategoryById,
    updateCategoryById,
    deleteCategoryById
} = ingredientsController;

router.post('/', createCategory);
router.get('/', getAllCategories);
router.get('/:id', getCategoryById);
router.put('/:id', updateCategoryById);
router.delete('/:id', deleteCategoryById);

module.exports = router;