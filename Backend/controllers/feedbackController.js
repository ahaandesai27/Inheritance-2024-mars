const Feedback = require('../models/Feedback');

const submitFeedback = async (req, res) => {
    const { title, description, user_id } = req.body;
    try {
        const feedback = new Feedback({ title, description, user: user_id });
        await feedback.save();
        res.status(201).send(feedback);
    } catch (error) {
        res.status(400).send(error);
    }
}   

module.exports = {
    submitFeedback
}