const User = require('../../models/User');

const handleLogout = async (req, res) => {
    // Note for Frontend: on client also delete the access token
    const cookies = req.cookies;
    if(!cookies?.jwt) return res.sendStatus(204); //No content

    // Clear the JWT cookie
    res.clearCookie('jwt', {httpOnly: true, sameSite:'None'});
    res.sendStatus(204);
}

module.exports =  handleLogout;