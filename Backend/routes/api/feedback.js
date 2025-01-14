const express = require('express');
const router = express.Router();

const {submitFeedback} = require('../../controllers/feedbackController.js');

router.post('/', submitFeedback);

module.exports = router;