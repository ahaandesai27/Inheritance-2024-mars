# This code was run in google colab 

import torch
import numpy as np
import pandas as pd
import os
import faiss
from ..training.embedder import RecipeEmbeddingModel
from dotenv import load_dotenv
from pymongo import MongoClient
from typing import List

load_dotenv()
MONGO_URI = os.environ.get("MONGO_URI")

def clean_ingredients(ingredients_str: str) -> List[str]:
    if pd.isna(ingredients_str):
        return []
    return [ing.strip() for ing in ingredients_str.split(',') if ing.strip()]

def process(df):
    df['_id'] = df['_id'].apply(str)
    df['Cleaned-Ingredients'] = df['Cleaned-Ingredients'].apply(clean_ingredients)
    df['ingredients_text'] = df['Cleaned-Ingredients'].apply(lambda x: ' '.join(x))
    df['Cleaned-Ingredients'] = df['Cleaned-Ingredients'].apply(lambda x: ', '.join(x))
    return df

class RecipeEmbedder:
    """
    Converts all the recipes in the database to vector embeddings based on their ingredients.
    """

    def __init__(self, model: RecipeEmbeddingModel, mongo_uri: str):
        self.model = model
        self.mongo_uri = mongo_uri

    def load_data(self):
        client = MongoClient(self.mongo_uri)
        df = pd.DataFrame(list(client["RecipAura"]["recipes"].find()))
        return process(df)

    def compute_and_save_embeddings(self, df: pd.DataFrame, batch_size=64):
        SAVE_DIR = "/content/drive/My Drive/recipe_embeddings"
        os.makedirs(SAVE_DIR, exist_ok=True)
        texts = df['ingredients_text'].tolist()

        # Get list of already saved batch files to skip
        existing_batches = set()
        for filename in os.listdir(SAVE_DIR):
            if filename.startswith("batch_") and filename.endswith(".npy"):
                # Extract batch start index from filename like batch_64.npy
                batch_num = int(filename[len("batch_"):-len(".npy")])
                existing_batches.add(batch_num)

        with torch.no_grad():
            for i in range(0, len(texts), batch_size):
                if i in existing_batches:
                    print(f"Skipping already processed batch {i}")
                    continue
                print(f"Started batch {i}")
                batch = texts[i:i+batch_size]
                emb = self.model(batch).cpu().numpy()
                faiss.normalize_L2(emb)
                np.save(os.path.join(SAVE_DIR, f"batch_{i}.npy"), emb)

        # Save metadata safely — include columns if they exist
        metadata_cols = [col for col in ['_id', 'title', 'ingredients_text'] if col in df.columns]
        df[metadata_cols].to_json(os.path.join(SAVE_DIR, "recipe_metadata.json"), orient='records')
        print("Saved all batches and metadata.")