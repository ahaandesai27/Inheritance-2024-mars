const User = require('../../models/User');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const handleLogin = async (req, res) => {
    const { username, password } = req.body;
    if(!username || !password) {
        res.status(400).send('Missing username or password');
        return;
    }

    // Check for username in DB
    const foundUser = await User.findOne({username}).exec();
    if(!foundUser) {
        res.status(401).send('Username or password is incorrect');
        return;
    }

    try {
        // Compare password
        const match = await bcrypt.compare(password, foundUser.password);
        if(match) {
            // Create JWT access token
            const accessToken = jwt.sign(
                {
                    "userInfo": {
                        "username": foundUser.username, 
                        "id": foundUser._id
                    }
                },
                process.env.ACCESS_TOKEN_SECRET, 
                {expiresIn: '30d'} 
            );

            res.status(200).json({accessToken});
        }
        else {
            res.status(401).send('Username or password is incorrect');
            return;
        }
    }
    catch (err) {
        res.status(500).send(`error: ${err.message}`);
    }
}

const changePassword = async (req, res) => {
    const { id, newPassword } = req.body;
    if (!id || !newPassword) {
        res.status(400).send('Missing id or newPassword');
        return;
    }

    try {
        const user = await User.findById(id).exec();
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        if (!hashedPassword) {
            res.status(500).send('Error hashing password');
            return;
        }
        if (hashedPassword == User.password) {
            res.status(400).send('New password is the same as the old password');
            return;
        }
        else {
            user.password = hashedPassword;
            await user.save();
            res.status(200).send('Password changed successfully');
        }
    } catch (error) {
        res.status(500).send(`error: ${error.message}`);
    }
}

module.exports =  {
    handleLogin,
    changePassword
}