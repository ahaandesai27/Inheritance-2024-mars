const User = require('../models/User');
 
const handleLogout = async (req, res) => {
    // Note for Frontend: on client also delete the access token
    const cookies = req.cookies;
    if(!cookies?.jwt) return res.sendStatus(204); //No content
    const refreshToken = cookies.jwt;
    //Is refreshToken in DB?
    const foundUser = await User.findOne({refreshToken}).exec();
    if(!foundUser) { //no user but cookie exists
        res.clearCookie('jwt', {httpOnly: true, sameSite:'None'});
        return res.sendStatus(204);
    }
    //delete refreshToken from DB
    foundUser.refreshToken = foundUser.refreshToken.filter(token => token !== refreshToken);
    const result = await foundUser.save();
    console.log(result);
    if(!result) return res.sendStatus(500);

    res.clearCookie('jwt', {httpOnly: true, sameSite:'None'});
    res.sendStatus(204);
}

module.exports =  handleLogout;