const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const userSchema = new Schema({
    username: {
        type: String,
        required: [true, 'Username is required'],
        trim: true
    },
    password: {
        type: String,
        required: [true, 'Password is required'],
        trim: true,
    },
    email: {
        type: String,
        required: [true, 'Email is required'],
        trim: true,
        unique: true
    },
    mobileNumber: {
        type: String,
        required: [true, 'Mobile number is required'],
        unique: true,
        trim: true
    },
    savedRecipes: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: 'recipes'
    },
    allergies: [String],
    refreshToken: [String],
    createdAt: {
        type: Date,
        default: Date.now
    }
});

const User = mongoose.model('User', userSchema);

module.exports = User;