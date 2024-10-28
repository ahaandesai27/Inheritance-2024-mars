const Recipe = require('../models/Recipe');

//get all Recipes
const getRecipes = async (req, res) => {
    try {
        const skip = parseInt(req.query.skip) || 0;
        const limit = parseInt(req.query.limit) || 10;
        const cuisine = req.query.cuisine;
        if(cuisine) {
            const recipes = await Recipe.find({Cuisine: cuisine}).skip(skip).limit(limit);
            if (recipes.length === 0) {
                return res.status(204).json({ error: `No recipes found for cuisine ${cuisine}` });
            }
            return res.json(recipes);
        }
        const recipes = await Recipe.find().skip(skip).limit(limit);
        if (recipes.length === 0) {
            return res.status(204).json({ error: 'No recipes found' });
        }
        res.json(recipes);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch recipes' });
    }
};

//create new ID and add to list
const createNewRecipe = async (req, res) => {
    if(!req?.body.firstname || !req?.body.lastname) {
        res.status(400).json({error: 'Please include both first and last name'});
    }
    try {
        console.log(req.body.firstName);
        console.log(req.body.lastName);
        const newRecipe = new Recipe({
            firstName: req.body.firstname,
            lastName: req.body.lastname
        });
        console.log(newRecipe);
        const result = await newRecipe.save();
        console.log(result)
        res.status(201).json(result);
    }
    catch(err) {
        res.status(500).json({error: err});
    }
}
//find by ID and update
const updateRecipe = async (req, res) => {
    // Write later
}
//find by ID and delete
const deleteRecipe = async (req, res) => {
    if(!req?.params?.id) {
        res.status(400).json({error: 'Please include Recipe ID'});
    }
    const id = req.params.id;
    const deletedRecipe = await Recipe.findOne({_id: id}).exec();
    if(!deletedRecipe) {
        res.status(204).json({error: `No Recipe with id ${id}`});
    } else {
        const result = await Recipe.deleteOne({_id: id});
        res.json(result);
    }
}   
//find by ID and return
const getRecipeById = async (req, res) => {
    if(!req?.params?.id) {
        res.status(400).json({error: 'Please include Recipe ID'});
    } 
    const id = req.params.id;
    const singleRecipe = await Recipe.findOne({_id: id}).exec();
    if(!singleRecipe) {
        res.status(204).json({error: `No Recipe with id ${id}`});
    } else {
        res.json(singleRecipe);
    }
}

module.exports = {
    getRecipes,
    createNewRecipe,
    updateRecipe,
    deleteRecipe,
    getRecipeById,
}