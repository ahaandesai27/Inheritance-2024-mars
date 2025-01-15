const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const Feedback = new Schema({
    title: {
        type: String,
        required: true,
        maxlength: 100
    },
    description: {
        type: String,
        required: true,
        maxlength: 1000
    },
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'users'
    },
    date: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('feedback', Feedback);