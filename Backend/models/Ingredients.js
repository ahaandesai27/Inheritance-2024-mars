const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const Ingredients = new Schema({
    name: {
        type: String,
        required: true,
        unique: true
    },
    category: {
        type: String,
        required: true
    }
});

module.exports = mongoose.model('ingredients', Ingredients);