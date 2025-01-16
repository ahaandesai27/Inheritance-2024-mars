const Recipe = require('../models/Recipe');


const autocomplete = async (req, res) => {
    const { q, limit = 5 } = req.query;
    console.log(q, limit)
    if (!q) {
        return res.status(400).json({ message: 'Query parameter "q" is required' });
    }

    try {
        const suggestions = await Recipe.aggregate([
            {
                $search: {
                    index: 'default',
                    autocomplete: {
                        query: q,
                        path: 'TranslatedRecipeName', 
                        fuzzy: { maxEdits: 1 }, // tolerates small typos
                    },
                },
            },
            { $limit: parseInt(limit) }, 
            { $project: { TranslatedRecipeName: 1, veg: 1} }, 
        ]);

        if (suggestions.length === 0) {
            return res.status(204).json({ message: 'No suggestions found' });
        }

        res.status(200).json(suggestions);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

const search = async (req, res) => {
    const { q, skip = 0, limit = 10 } = req.query;
    console.log(q)
    if (!q) {
        return res.status(400).json({ message: 'Search key is required' });
    }

    try {
        const results = await Recipe.aggregate([
            {
                $search: {
                    index: 'default',
                    text: {
                        query: q,
                        path: {
                            wildcard: '*',
                        },
                        fuzzy: {
                            maxEdits: 2,
                            prefixLength: q.length
                        },
                    },
                },
            },
            {
                $facet: {
                    data: [
                        { $skip: parseInt(skip) },
                        { $limit: parseInt(limit) },
                    ],
                },
            },
        ]);

        if (!results || !results[0]?.data?.length) {
            return res.status(204).json({ message: 'No results found' });
        }

        const { data } = results[0];
        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

module.exports = {
    autocomplete,
    search
}