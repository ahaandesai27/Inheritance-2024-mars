const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const userSchema = new Schema({
    username: {
        type: String,
        required: [true, 'Username is required'],
        trim: true
    },
    roles: {
        User: {
            type: String,
            default: 'user'
        },
        Editor: String,
        Admin: String
    },
    password: {
        type: String,
        required: [true, 'Password is required'],
        trim: true,
    },
    refreshToken: [String]
});

const User = mongoose.model('User', userSchema);

module.exports = User;