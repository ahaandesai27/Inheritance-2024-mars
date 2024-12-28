const express = require('express');
const router = express.Router();
const {
    addRecipeToDietPlan,
    getAllRecipesInDietPlan,
    deleteRecipeFromDietPlan
} = require('../../controllers/dietPlanController.js');

router
  .route('/:dietPlanId/recipes/:recipeId')
  .post(addRecipeToDietPlan)
  .delete(deleteRecipeFromDietPlan);

router.get('/:dietPlanId/recipes', getAllRecipesInDietPlan);
module.exports = router;