"""
Embeds recipes locally and stores the vectors in MongoDB, where they are
indexed by Atlas Vector Search.

The embedding lives on the recipe document itself (field `embedding`), so
recipe -> recipe recommendation only needs a lookup, no re-embedding.
"""

import time
from typing import List, Optional

from bson import ObjectId
from pymongo import UpdateOne
from pymongo.collection import Collection
from pymongo.errors import OperationFailure
from pymongo.operations import SearchIndexModel

from .. import db
from ..config import Config
from ..model.embedder import RecipeEmbeddingModel


def ingredients_text(recipe: dict) -> str:
    """`Cleaned-Ingredients` is comma separated - the model wants plain text."""
    raw = recipe.get("Cleaned-Ingredients") or ""
    parts = raw if isinstance(raw, list) else raw.split(",")
    return " ".join(part.strip() for part in parts if part.strip())


class RecipeEmbedder:
    """
    Converts recipes in the database to vector embeddings based on their
    ingredients, and writes them back to the same document.
    """

    def __init__(self, model: RecipeEmbeddingModel, collection: Collection = None,
                 config: Config = None):
        self.model = model
        self.config = config or Config()
        self.collection = collection if collection is not None else db.recipes()

    def embed_text(self, text: str) -> List[float]:
        """Embed free text (e.g. a list of ingredients typed by a user)."""
        return self.model.get_embedding(text).tolist()

    def embed_recipe(self, recipe_id) -> Optional[List[float]]:
        """
        Embed one recipe and store it. Used by the add-recipe flow so a new
        recipe is searchable right away.
        """
        recipe = self.collection.find_one({"_id": ObjectId(recipe_id)})
        if not recipe:
            return None

        vector = self.embed_text(ingredients_text(recipe))
        self.collection.update_one(
            {"_id": recipe["_id"]},
            {"$set": {self.config.EMBEDDING_FIELD: vector}},
        )
        return vector

    def embed_all(self, batch_size: int = 64, overwrite: bool = False,
                  progress: bool = True) -> int:
        """
        Backfill embeddings for the whole collection.
        By default only recipes that don't have one yet, so it can be re-run
        safely after a crash.
        """
        query = {} if overwrite else {self.config.EMBEDDING_FIELD: {"$exists": False}}
        pending = self.collection.count_documents(query)
        if not pending:
            if progress:
                print("nothing to embed - every recipe already has a vector")
            return 0
        if progress:
            print(f"embedding {pending} recipes (batch size {batch_size})")

        cursor = self.collection.find(query, {"Cleaned-Ingredients": 1})

        total, batch = 0, []
        for recipe in cursor:
            batch.append(recipe)
            if len(batch) == batch_size:
                total += self._write_batch(batch)
                batch = []
                if progress:
                    print(f"  embedded {total}/{pending}")

        if batch:
            total += self._write_batch(batch)

        if progress:
            print(f"done - embedded {total} recipes")
        return total

    def _write_batch(self, recipes: List[dict]) -> int:
        vectors = self.model.embed([ingredients_text(r) for r in recipes])
        self.collection.bulk_write([
            UpdateOne(
                {"_id": recipe["_id"]},
                {"$set": {self.config.EMBEDDING_FIELD: vector.tolist()}},
            )
            for recipe, vector in zip(recipes, vectors)
        ])
        return len(recipes)

    # --- Atlas Vector Search index -----------------------------------------

    def vector_index_status(self) -> Optional[str]:
        """`READY`, `PENDING`, ... or None when the index does not exist."""
        try:
            for index in self.collection.list_search_indexes():
                if index["name"] == self.config.VECTOR_INDEX_NAME:
                    return index.get("status")
        except OperationFailure:
            # Search indexes are an Atlas feature - a local mongod has no such
            # command, and that is worth saying plainly rather than crashing.
            raise RuntimeError(
                "This cluster does not support search indexes. Atlas Vector "
                "Search needs an Atlas cluster (M0 and up)."
            )
        return None

    def create_vector_index(self, wait: bool = False, timeout: int = 300) -> None:
        """
        Create the Atlas Vector Search index (run once, needs an Atlas cluster).
        Building the index is asynchronous - it takes a minute or two before
        queries return results. Pass `wait=True` to block until it is queryable.
        """
        if self.vector_index_status() is None:
            index = SearchIndexModel(
                name=self.config.VECTOR_INDEX_NAME,
                type="vectorSearch",
                definition={
                    "fields": [{
                        "type": "vector",
                        "path": self.config.EMBEDDING_FIELD,
                        "numDimensions": self.config.EMBEDDING_DIM,
                        "similarity": self.config.VECTOR_SIMILARITY,
                    }]
                },
            )
            self.collection.create_search_index(index)
            print(f"created index '{self.config.VECTOR_INDEX_NAME}' - building in the background")
        else:
            print(f"index '{self.config.VECTOR_INDEX_NAME}' already exists")

        if wait:
            self.wait_for_index(timeout=timeout)

    def wait_for_index(self, timeout: int = 300, poll: int = 5) -> bool:
        """Block until the index reports READY. False on timeout."""
        deadline = time.time() + timeout
        while time.time() < deadline:
            status = self.vector_index_status()
            if status == "READY":
                print(f"index '{self.config.VECTOR_INDEX_NAME}' is ready")
                return True
            print(f"  index status: {status} - waiting")
            time.sleep(poll)
        print(f"timed out after {timeout}s waiting for the index to build")
        return False


if __name__ == "__main__":
    config = Config()
    model = RecipeEmbeddingModel(config).load_weights()
    embedder = RecipeEmbedder(model, config=config)
    embedder.create_vector_index()
    embedder.embed_all()
