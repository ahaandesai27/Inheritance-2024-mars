import hashlib
import os
from contextlib import asynccontextmanager

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pymongo.errors import PyMongoError

from .. import cache, db
from ..config import Config
from ..model.embedder import RecipeEmbeddingModel
from ..recommender import RecipeEmbedder, RecipeSearcher
from .schemas import EmbedResponse, HealthResponse, RecommendRequest

config = Config()

model = RecipeEmbeddingModel(config).load_weights()
collection = db.recipes()
searcher = RecipeSearcher(model, collection, config)
embedder = RecipeEmbedder(model, collection, config)


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    db.close()
    cache.close()
    
app = FastAPI(title="Recipe Recommendation API", version="1.0.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler(PyMongoError)
async def mongo_error_handler(request: Request, exc: PyMongoError):
    # usually $vectorSearch rejected because the cluster is not atlas or the index does not exist yet
    detail = "Search backend unavailable"
    message = str(exc)
    if "$vectorSearch" in message or "index" in message.lower():
        detail = (f"Vector search failed - check that the Atlas index "
                  f"'{config.VECTOR_INDEX_NAME}' exists and is READY. ({message[:200]})")
    return JSONResponse(status_code=503, content={"detail": detail})


def _object_id(recipe_id: str) -> ObjectId:
    try:
        return ObjectId(recipe_id)
    except (InvalidId, TypeError):
        raise HTTPException(status_code=400, detail=f"'{recipe_id}' is not a valid recipe id")


@app.get("/health", response_model=HealthResponse)
def health_check():
    return {
        "status": "ok",
        "database": "up" if db.ping() else "down",
        "model_weights": "trained" if config.MODEL_WEIGHTS_PATH.exists() else "untrained",
    }

@app.post("/recommend")
async def get_recommendations(query: RecommendRequest):
    """Ingredients -> recipes. Embeds the query locally, then ANN."""
    ingredients = query.ingredients.strip()
    if not ingredients:
        raise HTTPException(status_code=400, detail="Ingredients list cannot be empty")

    top_k = query.k or 5
    # the query text is unbounded, so the key carries its digest
    digest = hashlib.sha256(ingredients.lower().encode()).hexdigest()
    key = f"{cache.KEY_PREFIX}recommend:{digest}:{top_k}"

    results = cache.get(key)
    if results is not None:
        return results

    results = searcher.search(ingredients, top_k=top_k)
    if results:
        cache.set(key, results)
    return results

@app.get("/similar/{recipe_id}")
async def get_similar_recipes(recipe_id: str, k: int = 5):
    """Recipe -> recipes. Reuses the embedding already stored on the recipe."""
    recipe_oid = _object_id(recipe_id)
    top_k = k if k > 0 else 5
    key = f"{cache.KEY_PREFIX}similar:{recipe_oid}:{top_k}"

    results = cache.get(key)
    if results is not None:
        return results

    results = searcher.search_by_recipe(recipe_oid, top_k=top_k)
    if not results:
        raise HTTPException(status_code=404, detail="Recipe not found or not embedded yet")

    cache.set(key, results)
    return results

@app.post("/embed/{recipe_id}")
async def embed_recipe(recipe_id: str):
    """Embed a newly added recipe and store it, so it becomes searchable."""
    vector = embedder.embed_recipe(_object_id(recipe_id))
    if vector is None:
        raise HTTPException(status_code=404, detail="Recipe not found")

    cache.invalidate_recommendations()
    return {
            "status": "ok",
            "recipe_id": recipe_id,
            "dim": len(vector)
        }

def main():
    """Console entry point: `recipe-api`."""
    import uvicorn

    uvicorn.run(app, host=config.HOST, port=int(os.environ.get("PORT", config.PORT)))


if __name__ == "__main__":
    main()
