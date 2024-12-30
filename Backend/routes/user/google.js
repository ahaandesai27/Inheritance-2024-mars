const express = require('express');
const router = express.Router();
const passport = require('passport');
const jwt = require('jsonwebtoken');
require('dotenv').config();
require('../../controllers/user/googleController'); 

router.get('/', passport.authenticate('google', { scope: ['email', 'profile'] }));
router.get('/callback', 
    passport.authenticate('google', { session: false }), 
    (req, res) => {
        const username = req.user.username;
        const id = req.user.id;
        const token = jwt.sign({ username, id }, process.env.ACCESS_TOKEN_SECRET, { expiresIn: '30d' });
        res.cookie('auth_token', token, {
            httpOnly: false,   // Prevent JavaScript from accessing the cookie
            secure: process.env.NODE_ENV === 'production', // Use HTTPS in production
            maxAge: 30 * 24 * 60 * 60 * 1000, // 30 days
        });

        res.redirect('http://localhost:5173');  // Frontend URL
    }
);


module.exports = router;