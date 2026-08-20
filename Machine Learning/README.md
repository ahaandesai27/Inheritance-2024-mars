# Recipe ML

Ingredient-based recipe recommendation. A MiniLM sentence encoder with a
contrastively trained projection head turns a recipe's ingredients into a
256-dimensional vector; recommendations are approximate nearest neighbour
(ANN) queries against **Atlas Vector Search**.

## Layout

```
Machine Learning/
├── src/recipe_ml/
│   ├── config.py               # all settings, env-driven, root-anchored paths
│   ├── db.py                   # shared MongoDB client — import this anywhere
│   ├── api/
│   │   ├── app.py              # FastAPI service
│   │   └── schemas.py          # request/response models
│   ├── model/embedder.py       # the network (encoder + projection head)
│   ├── recommender/
│   │   ├── searcher.py         # ANN queries ($vectorSearch)
│   │   └── vector_embedder.py  # writes vectors, manages the Atlas index
│   ├── training/               # data prep, contrastive loss, training loop
│   └── scripts/load_recipes.py # load → embed → index
├── data/                       # source corpus (gitignored)
├── model/                      # trained weights (gitignored)
└── Dockerfile
```

## Setup

```bash
uv sync                      # or: pip install -r requirements.txt
cp .env.example .env         # then fill in MONGO_URI
```

Every entry point below assumes `src/` is importable — `uv run` and an editable
install (`pip install -e .`) both handle it; otherwise set `PYTHONPATH=src`.

## Using the database

`db.py` owns one lazily created `MongoClient` for the whole project, so no
module opens its own connection pool.

```python
from recipe_ml.db import recipes, get_collection, get_db, ping

recipes().find_one({"Cuisine": "Indian"})    # the recipe collection
get_collection("feedback").count_documents({})
get_db().list_collection_names()
ping()                                       # False if the cluster is unreachable
```

For a short-lived script that shouldn't leave a pool open:

```python
from recipe_ml.db import mongo_client

with mongo_client() as client:
    ...
```

## Loading recipes

`load_recipes` runs three independent, re-runnable stages: **upsert → index → embed**.

```bash
python -m recipe_ml.scripts.load_recipes                       # everything
python -m recipe_ml.scripts.load_recipes --source data/x.json  # a specific file
python -m recipe_ml.scripts.load_recipes --skip-load           # embed what's already in Mongo
python -m recipe_ml.scripts.load_recipes --overwrite --wait    # re-embed all, block on the index
```

Accepts `.json` (records array or JSON-lines) and `.csv`. Recipes are keyed on
`URL` (falling back to name), so a second run updates rather than duplicating;
rows with no ingredients or no name are skipped. Only fields declared in the
Backend's `Recipe` schema are stored.

| flag | effect |
|---|---|
| `--source PATH` | recipe file to read (default: `DATA_PATH`) |
| `--skip-load` | don't read the file, just embed the database |
| `--drop` | delete every recipe first (asks for confirmation) |
| `--overwrite` | re-embed recipes that already have a vector |
| `--batch-size N` | recipes per embedding batch (default 64) |
| `--no-index` / `--wait` | skip index creation / block until it's `READY` |

## Serving

```bash
uvicorn recipe_ml.api.app:app --reload
```

| route | what it does |
|---|---|
| `GET /health` | status of the API, the database and the weights |
| `POST /recommend` | `{"ingredients": "...", "k": 5}` → ANN over the query embedding |
| `GET /similar/{recipe_id}` | ANN using the vector already stored on that recipe |
| `POST /embed/{recipe_id}` | embed a newly added recipe so it becomes searchable |

`/recommend` is pure ANN. `/similar` skips the encoder entirely — the recipe's
vector is already on the document — and drops the recipe itself from its own
results.

## Training

```bash
python -m recipe_ml.training.main
```

Writes a checkpoint per epoch **and** `model/model.pt`, which is the path both
the embedding job and the API load. This matters: the projection head is
randomly initialised, so if the API loads different weights than the ones used
to write the stored vectors, every similarity score is meaningless. After
retraining, re-embed:

```bash
python -m recipe_ml.scripts.load_recipes --skip-load --overwrite
```

`/health` reports `"model_weights": "untrained"` when `model/model.pt` is missing.

## Notes

- Vectors are L2-normalised, and the index uses `cosine`.
- `$vectorSearch` is Atlas-only; against a plain `mongod` the API returns 503
  with an explanation rather than a bare 500.
- Index builds are asynchronous — expect a minute or two before queries return
  results, or use `--wait`.
