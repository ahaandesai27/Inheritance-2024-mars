const express = require('express');
const router = express.Router();
const handleNewUser = require('../../controllers/user/registerController');

router.post('/', handleNewUser)

module.exports = router;