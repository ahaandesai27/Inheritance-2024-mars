const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth2').Strategy;
const User = require('../../models/User');
require('dotenv').config();

const generateUniqueUsername = async (baseUsername, serviceProvider) => {
  let username = baseUsername;
  let user = await User.findOne({ username });
  if (user) {
    username = `${baseUsername}_${serviceProvider}`;
  }
  return username;
};

passport.use(new GoogleStrategy({
    clientID: process.env.OAUTH2_CLIENT_ID,
    clientSecret: process.env.OAUTH2_CLIENT_SECRET,
    callbackURL: 'http://localhost:4000/auth/google/callback', 
    passReqToCallback: true
  },
  async function(request, accessToken, refreshToken, profile, done) {
    try {
      let user = await User.findOne({ googleId: profile.id });
      const baseUsername = profile.email.split('@')[0];
      const serviceProvider = profile.email.split('@')[1].split('.')[0];   
      // first split by @ because part before @ can also contain '.'
      const username = await generateUniqueUsername(baseUsername, serviceProvider);
      if (!user) {
        user = new User({
          googleId: profile.id,
          username,
          firstName: profile.displayName.split(' ')[0],
          lastName: profile.displayName.split(' ')[1],
          email: profile.email,
          mobileNumber: null
        });
        await user.save();
      }
      return done(null, user);
    } catch (err) {
      return done(err);
    }
  }
));

passport.serializeUser((user, done) => {
  done(null, user.id);
});

passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id);
    done(null, user);
  } catch (err) {
    done(err, null);
  }
});