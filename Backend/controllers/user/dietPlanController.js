const DietPlan = require('../../models/DietPlan');
const User = require('../../models/User');

const createDietPlan = async (req, res) => {
    // name, desc required
    try {
        const { userId } = req.params;
        const { name, description } = req.body;
        if (!name) {
            return res.status(400).json({ message: 'Name is required' });
        }
        const dietPlan = await DietPlan.create({name, description, user: userId});

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        user.dietPlans.push(dietPlan._id);
        await user.save();

        res.status(201).json(dietPlan);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const fetchDietPlans = async (req, res) => {
    // fetches name, desc , ID and other information -> click on it to get the recipes
    try {
        const { userId } = req.params;
        const user = await User.findById(userId).populate('dietPlans');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.json(user.dietPlans);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const editDietPlan = async (req, res) => {
    try {
        const { dietPlanId } = req.params;
        const updatedDietPlan = await DietPlan.findByIdAndUpdate(dietPlanId, req.body, { new: true });
        if (!updatedDietPlan) {
            return res.status(404).json({ message: 'Diet Plan not found' });
        }
        res.status(200).json(updatedDietPlan);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const deleteDietPlan = async (req, res) => {
    try {
        const { dietPlanId, userId } = req.params;
        const dietPlan = await DietPlan.findByIdAndDelete(dietPlanId);
        if (!dietPlan) {
            return res.status(404).json({ message: 'Diet Plan not found' });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        user.dietPlans.pull(dietPlanId);
        await user.save();

        res.status(200).json({ message: 'Diet Plan deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

module.exports = { createDietPlan, fetchDietPlans, editDietPlan, deleteDietPlan };