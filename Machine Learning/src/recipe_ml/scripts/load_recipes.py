import argparse
import json
import sys
from pathlib import Path
from typing import Iterator, List

from pymongo import UpdateOne
from pymongo.collection import Collection

from .. import cache, db
from ..config import Config
from ..model.embedder import RecipeEmbeddingModel
from ..recommender.vector_embedder import RecipeEmbedder

# Fields the Backend's Recipe schema declares; anything else is dropped.
RECIPE_FIELDS = [
    "TranslatedRecipeName",
    "TranslatedIngredients",
    "TotalTimeInMins",
    "Cuisine",
    "TranslatedInstructions",
    "URL",
    "Cleaned-Ingredients",
    "image-url",
    "Ingredient-count",
    "calorieCount",
    "veg",
]


def read_recipes(path: Path) -> List[dict]:
    if not path.exists():
        raise FileNotFoundError(
            f"no recipe file at {path} - pass --source, or set DATA_PATH in .env"
        )

    suffix = path.suffix.lower()
    if suffix == ".csv":
        import pandas as pd

        return pd.read_csv(path).to_dict(orient="records")

    if suffix in (".json", ".jsonl", ".ndjson"):
        text = path.read_text()
        stripped = text.lstrip()
        if stripped.startswith("["):
            return json.loads(text)
        # JSON-lines, what data_processor.save_data writes
        return [json.loads(line) for line in text.splitlines() if line.strip()]

    raise ValueError(f"unsupported file type '{suffix}' - use .json, .jsonl or .csv")


def clean(recipe: dict) -> dict:
    doc = {key: recipe[key] for key in RECIPE_FIELDS if key in recipe and recipe[key] is not None}

    # the training pipeline makes this a list; the database wants the text form
    cleaned = doc.get("Cleaned-Ingredients")
    if isinstance(cleaned, list):
        doc["Cleaned-Ingredients"] = ", ".join(str(part).strip() for part in cleaned if str(part).strip())

    # instructions are a list of steps in the schema
    instructions = doc.get("TranslatedInstructions")
    if isinstance(instructions, str):
        doc["TranslatedInstructions"] = [
            step.strip() for step in instructions.split("\n") if step.strip()
        ]

    return doc


def key_for(recipe: dict) -> dict:
    """The natural key used to upsert - URL when present, else the name."""
    if recipe.get("URL"):
        return {"URL": recipe["URL"]}
    return {"TranslatedRecipeName": recipe.get("TranslatedRecipeName")}


def batched(items: List[dict], size: int) -> Iterator[List[dict]]:
    for start in range(0, len(items), size):
        yield items[start:start + size]


def load_into_mongo(collection: Collection, recipes: List[dict], batch_size: int = 500) -> dict:
    """Upsert recipes. Returns counts of inserted / updated documents."""
    inserted = updated = skipped = 0

    for chunk in batched(recipes, batch_size):
        operations = []
        for raw in chunk:
            doc = clean(raw)
            if not doc.get("Cleaned-Ingredients") or not doc.get("TranslatedRecipeName"):
                # nothing to embed, or nothing to show
                skipped += 1
                continue
            operations.append(UpdateOne(key_for(doc), {"$set": doc}, upsert=True))

        if not operations:
            continue

        result = collection.bulk_write(operations, ordered=False)
        inserted += result.upserted_count
        updated += result.modified_count
        print(f"  upserted {inserted + updated}/{len(recipes)}")

    return {"inserted": inserted, "updated": updated, "skipped": skipped}


def main(argv=None) -> int:
    config = Config()

    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--source", type=Path, default=config.DATA_PATH,
                        help=f"recipe file to load (default: {config.DATA_PATH})")
    parser.add_argument("--skip-load", action="store_true",
                        help="do not read the source file, just embed what is in the database")
    parser.add_argument("--drop", action="store_true",
                        help="delete every recipe before loading - destructive")
    parser.add_argument("--overwrite", action="store_true",
                        help="re-embed recipes that already have a vector")
    parser.add_argument("--batch-size", type=int, default=64,
                        help="recipes per embedding batch (default: 64)")
    parser.add_argument("--no-index", action="store_true",
                        help="skip creating the Atlas Vector Search index")
    parser.add_argument("--wait", action="store_true",
                        help="block until the vector index finishes building")
    args = parser.parse_args(argv)

    collection = db.recipes()
    print(f"database: {config.MONGO_DB}.{config.RECIPE_COLLECTION}")

    if not db.ping():
        print("cannot reach MongoDB - check MONGO_URI in .env", file=sys.stderr)
        return 1

    # 1. load
    if args.drop:
        confirm = input(f"delete all {collection.count_documents({})} recipes? [y/N] ")
        if confirm.strip().lower() != "y":
            print("aborted")
            return 1
        collection.delete_many({})

    if not args.skip_load:
        print(f"reading {args.source}")
        recipes = read_recipes(args.source)
        print(f"read {len(recipes)} recipes")
        stats = load_into_mongo(collection, recipes)
        print(f"loaded - {stats['inserted']} new, {stats['updated']} updated, "
              f"{stats['skipped']} skipped")

    # 2. index
    model = RecipeEmbeddingModel(config).load_weights()
    embedder = RecipeEmbedder(model, collection, config)

    if not args.no_index:
        embedder.create_vector_index(wait=args.wait)

    # 3. embed
    embedder.embed_all(batch_size=args.batch_size, overwrite=args.overwrite)
    # this path never touches /embed, so nothing else drops the stale results
    cache.invalidate_recommendations()

    total = collection.count_documents({})
    embedded = collection.count_documents({config.EMBEDDING_FIELD: {"$exists": True}})
    print(f"\n{embedded}/{total} recipes are searchable")
    db.close()
    cache.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
