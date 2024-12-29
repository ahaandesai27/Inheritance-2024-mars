const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const userSchema = new Schema({
    username: {
        type: String,
        trim: true,
        unique: true
    },
    password: {
        type: String,
        trim: true,
    },
    firstName: {
        type: String,
        required: [true, 'First name is required'],
        trim: true
    },
    lastName: {
        type: String,
        required: [true, 'Last name is required'],
        trim: true
    },
    googleId: {
        type: String,
        unique: true
    },
    email: {
        type: String,
        required: [true, 'Email is required'],
        trim: true,
        unique: true
    },
    mobileNumber: {
        type: String,
        unique: true,
        trim: true
    },
    savedRecipes: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: 'recipes'
    },
    history: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: 'recipes'
    },
    allergies: [String],
    refreshToken: [String],
    createdAt: {
        type: Date,
        default: Date.now
    },
    vegetarian: {
        type: Boolean,
        default: false
    },
    dietPlans: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: 'dietplans'
    }
});

const User = mongoose.model('User', userSchema);

module.exports = User;