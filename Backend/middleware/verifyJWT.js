const jwt = require('jsonwebtoken');

const verifyJWT = (req, res, next) => {
    //check for access token in header
    const authHeader = req.headers.authorization||req.headers.Authorization;
    if(!authHeader?.startsWith('Bearer ')) {
        res.status(401).send('Access denied, token missing');
        return;
    }
    //verify access token
    console.log(authHeader);
    const accessToken = authHeader.split(' ')[1]; //get token number from {Bearer <token>}
    jwt.verify(
        accessToken, 
        process.env.ACCESS_TOKEN_SECRET,
        (err, decoded) => {
            if(err) {
                res.status(403).send('Invalid token');
            }
            req.user = decoded.userInfo.username; //set usesrname of cur user
            req.roles = decoded.userInfo.roles; //set roles of cur user
            next();
    });
}

module.exports = verifyJWT;