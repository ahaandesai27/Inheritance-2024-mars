const express = require('express');
const router = express.Router();
const { handleLogin, changePassword } = require('../../controllers/user/loginController');

router.post('/', handleLogin)
router.post('/changePassword', changePassword)

module.exports = router;