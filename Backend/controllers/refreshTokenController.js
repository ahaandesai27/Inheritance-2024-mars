const User = require('../models/User');
const jwt = require('jsonwebtoken');

const handleRefreshToken = async (req, res) => {
    
    const cookies = req.cookies;
    if(!cookies?.jwt) return res.sendStatus(401);
    
    const refreshToken = cookies.jwt;
    res.clearCookie('jwt', {httpOnly: true, sameSite:'None'});
    
    //check for username in DB
    const foundUser = await User.findOne({refreshToken}).exec();
    if(!foundUser){ 
        //if no user but someone is trying to use the refresh token
        jwt.verify(
            refreshToken,
            process.env.REFRESH_TOKEN_SECRET,
            async (err, decoded) => {
                if(err) return res.sendStatus(403); //Forbidden
                //delete refreshToken from DB
                const result = await User.updateOne(
                    {username: decoded.userInfo.username},
                    {$set: {refreshToken: []}}
                );
                console.log(result);
                if(!result) return res.sendStatus(500);
            }
        );
        return res.sendStatus(403);
    }
    try {
        //compare refresh token
        const newRefreshTokenArray = foundUser.refreshToken.filter(token => token !== refreshToken);

        jwt.verify(
            refreshToken,
            process.env.REFRESH_TOKEN_SECRET,
            async (err, decoded) => {
                if(err) {
                    //delete wrong refreshToken from DB if user found
                    foundUser.refreshToken = newRefreshTokenArray;
                    const result = await foundUser.save();
                    console.log(result);
                    if(!result) return res.sendStatus(500);
                    return res.sendStatus(403); //Forbidden
                }

                if(err || foundUser.username !== decoded.userInfo.username) return res.sendStatus(403);

                const roles = Object.values(foundUser.roles);
                const accessToken = jwt.sign(
                    {
                        "userInfo":{
                            "username": foundUser.username,
                            "roles": roles
                        }
                    },
                    process.env.ACCESS_TOKEN_SECRET,
                    {expiresIn: '3d'}
                );
                const newRefreshToken = jwt.sign(
                    {
                        "userInfo": {
                            "username": foundUser.username, 
                            "roles": roles
                        }
                    }, 
                    process.env.REFRESH_TOKEN_SECRET, 
                    {expiresIn: '15d'}
                );
                //save refresh token to current user
                foundUser.refreshToken= [...newRefreshTokenArray, newRefreshToken];
                const result = await foundUser.save();
                console.log(result);
                res.cookie('jwt', newRefreshToken, {httpOnly: true, sameSite:'None', maxAge: 24*60*60*1000});
    
                res.status(200).json({roles,accessToken});
            }
        );
    }
    catch (err) {
        res.status(500).send(`error: ${err.message}`);
    }
}

module.exports =  handleRefreshToken;