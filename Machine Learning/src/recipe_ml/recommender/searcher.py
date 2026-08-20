from typing import List, Optional

from bson import ObjectId
from pymongo.collection import Collection

from .. import db
from ..config import Config
from ..model.embedder import RecipeEmbeddingModel


class RecipeSearcher:
    def __init__(self, model: RecipeEmbeddingModel, collection: Collection = None,
                 config: Config = None):
        self.model = model
        self.collection = collection if collection is not None else db.recipes()
        self.config = config or Config()

    def search(self, ingredients: str, top_k: int = 5) -> List[dict]:
        """Ingredient text -> similar recipes."""
        vector = self.model.get_embedding(ingredients).tolist()
        return self._vector_search(vector, top_k)

    def search_by_recipe(self, recipe_id, top_k: int = 5) -> List[dict]:
        """Recipe -> similar recipes, using the vector stored on the document."""
        recipe = self.collection.find_one(
            {"_id": ObjectId(recipe_id)},
            {self.config.EMBEDDING_FIELD: 1},
        )
        vector = recipe.get(self.config.EMBEDDING_FIELD) if recipe else None
        if not vector:
            return []
        # the recipe is its own nearest neighbour, so ask for one extra and drop it
        results = self._vector_search(vector, top_k + 1, exclude_id=recipe["_id"])
        return results[:top_k]

    def _vector_search(self, vector: List[float], top_k: int,
                       exclude_id: Optional[ObjectId] = None) -> List[dict]:
        pipeline = [
            {
                "$vectorSearch": {
                    "index": self.config.VECTOR_INDEX_NAME,
                    "path": self.config.EMBEDDING_FIELD,
                    "queryVector": vector,
                    "numCandidates": top_k * self.config.NUM_CANDIDATES_MULTIPLIER,
                    "limit": top_k,
                }
            },
            {"$project": {self.config.EMBEDDING_FIELD: 0}},
            {"$set": {"similarity": {"$meta": "vectorSearchScore"}}},
        ]

        results = []
        for doc in self.collection.aggregate(pipeline):
            if exclude_id is not None and doc["_id"] == exclude_id:
                continue
            doc["_id"] = str(doc["_id"])
            results.append(doc)
        return results
