import torch
import pandas as pd
import heapq
from sentence_transformers import SentenceTransformer
from torch import nn
from typing import List
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from config.config import Config

class RecipeEmbeddingModel(nn.Module):
    def __init__(self, config: Config):
        super().__init__()
        self.config = config
        self.transformer = SentenceTransformer(config.BASE_MODEL)
        
        # Add a projection layer after BERT (MiniLM)
        self.projection = nn.Sequential(
            nn.Linear(384, 256),  # 384 is the default embedding size for MiniLM
            nn.ReLU(),
            nn.Linear(256, 256)
        )
        
    def forward(self, texts: List[str]):
        # Get BERT embeddings
        embeddings = self.transformer.encode(texts, convert_to_tensor=True)
        # Project embeddings
        projected = self.projection(embeddings)
        return projected
    
    def get_embedding(self, text: str) -> np.ndarray:
        with torch.no_grad():
            embedding = self.transformer.encode([text], convert_to_tensor=True)
            projected = self.projection(embedding)
            return projected.cpu().numpy()[0]

class RecipeRecommender:
    def __init__(self, model: RecipeEmbeddingModel, df: pd.DataFrame):
        self.model = model
        self.df = df
        self.recipe_embeddings = None
        self.compute_all_embeddings()
        
    def compute_all_embeddings(self):
        with torch.no_grad():
            self.recipe_embeddings = self.model(self.df['ingredients_text'].tolist())      
            # compute embeddings for all recipes
            self.recipe_embeddings = self.recipe_embeddings.cpu().numpy()
    
    def find_similar_recipes(self, query: str, n_recommendations: int = 5) -> List[dict]:
        query_embedding = self.model.get_embedding(query)
        similarities = cosine_similarity([query_embedding], self.recipe_embeddings)[0]
        top_indices = heapq.nlargest(n_recommendations, range(len(similarities)), key=lambda idx: similarities[idx])
        recommendations = []
        for idx in top_indices:
            recipe_data = self.df.iloc[idx].to_dict()
            recipe_data['similarity'] = similarities[idx]
            recommendations.append(recipe_data)
        return recommendations