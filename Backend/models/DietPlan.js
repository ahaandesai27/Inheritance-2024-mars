const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const DietPlan = new Schema({
    name: {
        type: String,
        required: true
    },
    description: {
        type: String,
    },
    recipes: [{
        type: Schema.Types.ObjectId,
        ref: 'recipes'
    }],
    createdAt: {
        type: Date,
        default: Date.now
    },
    image: {
        type: String,
    },
    user: {
        type: Schema.Types.ObjectId,
        ref: 'user'
    }
});

module.exports = mongoose.model('dietplans', DietPlan);