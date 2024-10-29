const express = require('express');
const app = express();
const path = require('path');
const cors = require('cors');
const corsOptions = require('./config/corsOptions');
const {logger} = require('./middleware/logEvents');
const errorHandler = require('./middleware/errorHandler');
const verifyJWT = require('./middleware/verifyJWT');
const cookieParser = require('cookie-parser');
const credentials = require('./middleware/credentials');
const mongoose = require('mongoose');
const connectDB = require('./config/dbConnection');
const PORT = process.env.PORT || 3500;
require('dotenv').config();
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
app.use('/',express.static(path.join(__dirname, 'public')));
app.use(cookieParser());

//routes
app.use('/register', require('./routes/register'));
app.use('/auth', require('./routes/auth'));
app.use('/refresh', require('./routes/refresh'));
app.use('/logout', require('./routes/logout'));
// app.use(verifyJWT) 
app.use('/api/recipes', require('./routes/api/recipes'));
app.use('/api/ingredients', require('./routes/api/crawlers'));
// Nothing found
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
