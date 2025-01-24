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

query_ingredients = """tomatoes chilli chicken"""
recommendations = recommender.find_similar_recipes(query_ingredients, n_recommendations=5)

print("\nRecommendations:")
for recipe_name, score in recommendations:
    print(f"{recipe_name}: {score:.4f}")
