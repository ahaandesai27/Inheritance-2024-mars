from .recommender.searcher import RecipeSearcher
from .training.embedder import RecipeEmbeddingModel
from .config.config import Config

from bson import ObjectId
from pymongo import MongoClient
from dotenv import load_dotenv
import os 

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import uvicorn
# Environment variables
load_dotenv()
mongo_uri = os.getenv("MONGO_URI")

# Model and searcher
model = RecipeEmbeddingModel(Config())
searcher = RecipeSearcher(model)

# MongoDB connection
client = MongoClient(mongo_uri)
db = client["RecipAura"]
collection = db["recipes"]

# FastAPI
app = FastAPI(title="Recipe Recommendation API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class RecommendRequest(BaseModel):
    ingredients: str
    k: Optional[int] = 5

@app.get('/health')
def health_check():
    return {"status": "ok"}

@app.post('/recommend')
async def get_recommendations(query: RecommendRequest):
    ingredients = query.ingredients.strip()
    k = query.k if query.k and query.k > 0 else 5

    if not ingredients:
        raise HTTPException(status_code=400, detail="Ingredients list cannot be empty")

    if len(ingredients.split(",")) <= 5:
        split_ingredients = ingredients.split(",")
        regex_filters = [{"Cleaned-Ingredients": {"$regex": ingredient, "$options": "i"}} for ingredient in split_ingredients]

        # Mongo query: documents that contain all ingredients (AND)
        # If you want documents that contain any ingredients (OR), use $or instead of $and
        query_filter = {"$or": regex_filters}

        cursor = collection.find(query_filter)
        recommendations = []
        for doc in cursor:
            doc['_id'] = str(doc['_id'])
            recommendations.append(doc)
            if len(recommendations) >= k:
                break
        return recommendations
    else: 
        results = searcher.search(ingredients, top_k=k)
        recommendations = []

        for r in results:
            data = collection.find_one({'_id': ObjectId(r['_id'])})
            if data:
                data['_id'] = str(data['_id'])
                recommendations.append(data)
        
        return recommendations

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
    
