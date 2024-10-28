const User = require('../models/User');
const bcrypt = require('bcrypt');

const handleNewUser = async (req, res) => {
    const { username, password } = req.body;
    if(!username || !password) {
        res.status(400).send('Missing username or password');
        return;
    }
    //check for duplicate username in DB
    const duplicate = await User.findOne({username}).exec();
    if(duplicate) { 
        res.status(409).send('Username already exists');
        return;
    }

    try {
        //hash password
        const hashedPassword = await bcrypt.hash(password, 10);
        //add new user to DB
        const result = await User.create({ 
            username,
            password: hashedPassword 
        });
        console.log(result);
        res.status(201).send(`New user ${username} created!`);
    }
    catch (err) {
        res.status(500).send(`error: ${err.message}`);
    }
}

module.exports =  handleNewUser;