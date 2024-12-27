const { fetchUserById, fetchUserByUsername } = require('../../controllers/user/fetchController');
const express = require('express');
const router = express.Router();

router.get('/id/:userId', fetchUserById)
router.get('/:username', fetchUserByUsername)

module.exports = router;