const express = require('express');
const router = express.Router();
const handleLogout = require('../../controllers/user/logoutController');

router.get('/', handleLogout)

module.exports = router;