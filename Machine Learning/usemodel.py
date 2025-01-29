import torch
import pandas as pd
from config.config import Config
from models.model import RecipeEmbeddingModel, RecipeRecommender

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
config = Config()
model = RecipeEmbeddingModel(config)
model.load_state_dict(torch.load('saved_models/model_epoch_10.pt', map_location=device, weights_only=True))
model.eval()
model = model.to(device)

df = pd.read_csv('./recipes.csv')
recommender = RecipeRecommender(model, df)

query_ingredients = "chicken"

filtered_df = df[
    df['TranslatedRecipeName'].str.contains(query_ingredients, case=False, na=False) | 
    df['Cleaned-Ingredients'].str.contains(query_ingredients, case=False, na=False)
]

if not filtered_df.empty:
    filtered_recommender = RecipeRecommender(model, filtered_df)
    recommendations = filtered_recommender.find_similar_recipes(query_ingredients, n_recommendations=5)
else:
    recommendations = recommender.find_similar_recipes(query_ingredients, n_recommendations=5)

print("\nRecommendations with Full Recipes:")
for i, (item) in enumerate(recommendations, start=1):
    print(item)