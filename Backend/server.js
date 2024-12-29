const express = require('express');
const app = express();
const path = require('path');
const cors = require('cors');
const corsOptions = require('./config/corsOptions');
const {logger} = require('./middleware/logEvents');
const errorHandler = require('./middleware/errorHandler');
const verifyJWT = require('./middleware/verifyJWT');
const credentials = require('./middleware/credentials');
const mongoose = require('mongoose');
const connectDB = require('./config/dbConnection');
const passport = require('passport');

require('./controllers/user/googleController')
require('dotenv').config();
const PORT = process.env.PORT || 3500;
// Connect to DB
connectDB();
//custom middleware logger
app.use(logger);

//Handles options credentials check - before CORS
//fetch cookies credentials requirement
app.use(credentials);

//cors
app.use(cors(corsOptions));

//middleware
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// authentication
app.use('/register', require('./routes/user/register'));
app.use('/login', require('./routes/user/login'));            // Login
app.use('/logout', require('./routes/user/logout'));
app.get('/auth/google', passport.authenticate('google', { scope: ['email', 'profile'] }));
app.get('/auth/google/callback', 
    passport.authenticate('google', { session: false }), 
    (req, res) => {
        res.json({ message: 'Login successful!', user: req.user });
    }
);

// app.use(verifyJWT) 

// Normal routes
app.use('/api/recipes', require('./routes/api/recipes'));
app.use('/api/getingredients', require('./routes/api/crawlers'));
app.use('/api/ingredients', require('./routes/api/ingredients'));
app.use('/api/dietplan', require('./routes/api/dietplans'));

// User routes 
app.use('/api/user', require('./routes/user/fetch'));
app.use('/api/user/recipes', require('./routes/user/recipes'));   
app.use('/api/user/dietplans', require('./routes/user/dietplans'));

// 404 
app.all('*', (req, res) => {
    res.status(404);
    if(req.accepts('json')) {
        res.json({error: 'Not found'});
    } else {
        res.type('txt').send('Not found');
    }
})

app.use(errorHandler);

mongoose.connection.once('open', () => {
    console.log('MongoDB connection ready');
    app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
});
