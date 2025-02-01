# Recipe Recommendation System

This project is an API for recommending recipes based on given ingredients using a transformer based recommender system.

## API Documentation

### `/recommend/` - Get Recipe Recommendations

#### Request
- **Method**: POST
- **URL**: `/recommend/`
- **Request Body Parameters**:
  - `ingredients` (string): A comma-separated list of ingredients to base the recommendations on.
  - `num_recommendations` (integer): The number of recipe recommendations to return.

#### Response
- **Response Type**: JSON
- **Response Model**: `List[RecipeRecommendation]`

Each recommended recipe is returned with the following fields:
- `TranslatedRecipeName`: Name of the recommended recipe.
- `TranslatedIngredients`: Ingredients required for the recipe.
- `TotalTimeInMins`: Total time (in minutes) required to make the recipe.
- `Cuisine`: The cuisine type of the recipe.
- `TranslatedInstructions`: Cooking instructions for the recipe.
- `URL`: Optional URL to the recipe (if available).
- `Cleaned-Ingredients`: Cleaned ingredients list for processing.
- `image-url`: URL of the recipe image.
- `Ingredient-count`: Number of ingredients in the recipe.
- `calorieCount`: Estimated calorie count for the recipe.
- `veg`: Boolean indicating whether the recipe is vegetarian.



## Setup

To set up the API, clone the repository and install the required dependencies:

```bash
git clone <repository_url>
cd <repository_directory>
pip install -r requirements.txt
```e

Run the API:

```bash
python -m uvicorn app:app --reload
```

The API will be available at `http://127.0.0.1:8000`.

## Notes
- The recommendation system uses a pre-trained model (`model`) and a dataset (`recipes.json`), which should be properly configured and preprocessed for optimal results. Contact me for access to the dataset.
