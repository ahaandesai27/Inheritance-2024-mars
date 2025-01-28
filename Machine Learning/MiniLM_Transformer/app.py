from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import torch
import pandas as pd
import numpy as np
from typing import List
from config.config import Config
from models.model import RecipeEmbeddingModel, RecipeRecommender


app = FastAPI(title="Recipe Recommendation API")

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
config = Config()
model = RecipeEmbeddingModel(config)
model.load_state_dict(torch.load('saved_models/model_epoch_10.pt', map_location=device, weights_only=True))
model.eval()
model = model.to(device)
recipe_df = pd.read_csv('./recipes.csv')
recommender = RecipeRecommender(model, df=recipe_df)

class RecipeQuery(BaseModel):
    ingredients: str
    num_recommendations: int = 5

class RecipeRecommendation(BaseModel):
    TranslatedRecipeName: str
    TranslatedIngredients: str
    TotalTimeInMins: int
    Cuisine: str
    TranslatedInstructions: str
    URL: str = None
    Cleaned_Ingredients: str
    image_url: str = Field(..., alias='image-url')
    Ingredient_count: int = Field(..., alias='Ingredient-count')
    calorieCount: int
    veg: bool

    class Config:
        allow_population_by_field_name = True

@app.post("/recommend/", response_model=List[RecipeRecommendation])
async def get_recipe_recommendations(query: RecipeQuery):
    if not query.ingredients.strip():
        raise HTTPException(status_code=400, detail="Ingredients list cannot be empty")
    if query.num_recommendations < 1:
        raise HTTPException(status_code=400, detail="Number of recommendations must be positive")
    
    try:
        recommendations = recommender.find_similar_recipes(
            query.ingredients, 
            n_recommendations=query.num_recommendations
        )
        
        recommendation_list = []
        for recipe in recommendations:
            recipe_data = {key: (float(value) if isinstance(value, np.float32) else value) for key, value in recipe.items()}
            recommendation_list.append(
                RecipeRecommendation(
                    TranslatedRecipeName=recipe_data['TranslatedRecipeName'],
                    TranslatedIngredients=recipe_data['TranslatedIngredients'],
                    TotalTimeInMins=int(recipe_data['TotalTimeInMins']),
                    Cuisine=recipe_data['Cuisine'],
                    TranslatedInstructions=recipe_data['TranslatedInstructions'],
                    URL=recipe_data.get('URL', None),
                    Cleaned_Ingredients=recipe_data['Cleaned-Ingredients'],
                    image_url=recipe_data['image-url'],
                    Ingredient_count=int(recipe_data['Ingredient-count']),
                    calorieCount=int(recipe_data['calorieCount']),
                    veg=bool(recipe_data['veg'])
                )
            )
        
        return recommendation_list

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="localhost", port=8080)
