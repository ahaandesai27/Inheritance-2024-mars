const express = require('express');
const router = express.Router();
const {
    createDietPlan,
    fetchDietPlans,
    editDietPlan,
    deleteDietPlan
} = require('../../controllers/user/dietPlanController.js');

router.post('/:userId', createDietPlan);
router.get('/:userId', fetchDietPlans);
router.put('/:dietPlanId', editDietPlan);
router.delete('/:userId/:dietPlanId', deleteDietPlan);

module.exports = router;