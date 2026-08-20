# Setup & Run

Everything you need to do, in order, from a fresh clone to a serving API.

All commands run from the `Machine Learning/` directory.

---

## Step 0 — Prerequisites

| Need | Why |
|---|---|
| Python 3.12 | pinned in `.python-version` |
| A **MongoDB Atlas** cluster (M0 free tier is fine) | `$vectorSearch` does not exist on a self-hosted `mongod` — the API will return 503 |
| ~2 GB disk | `torch` + `sentence-transformers` |

You already have the cluster: the Backend talks to it via `DATABASE_URI` in `Backend/.env`. Same cluster, same `recipes` collection.

---

## Step 1 — Install dependencies

```bash
uv sync
```

or, without uv:

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

`uv sync` and `pip install -e .` both make `src/` importable. If you use a plain
`pip install -r requirements.txt`, prefix commands with `PYTHONPATH=src`.

---

## Step 2 — Fill in `.env`

**This is the one thing that is currently blocking you.** `Machine Learning/.env`
exists but `MONGO_URI` is empty, so nothing can reach the database.

```bash
cp .env.example .env    # skip if you want to keep the existing file
```

Then set `MONGO_URI` to the same connection string the Backend uses — copy the
value of `DATABASE_URI` from `Backend/.env`:

```ini
MONGO_URI=mongodb+srv://<user>:<password>@<cluster>/?retryWrites=true&w=majority
MONGO_DB=RecipAura
RECIPE_COLLECTION=recipes
```

Check it:

```bash
python -c "from recipe_ml.db import ping; print('connected:', ping())"
```

Expect `connected: True`. If it prints `False`, the URI is wrong or your IP is
not on the Atlas access list.

---

## Step 3 — Get the recipe corpus into `data/`

Training reads from a **file**, not from Mongo. Pick whichever case you're in.

**Case A — you have the recipe JSON/CSV.** Drop it at `data/recipes.json`
(a records array, JSON-lines, or `.csv` all work), or point `DATA_PATH` at it in `.env`.

**Case B — the recipes are only in Atlas already.** Export them first:

```bash
python -c "
import json
from recipe_ml.db import recipes
docs = list(recipes().find({}, {'_id': 0, 'embedding': 0}))
with open('data/recipes.json', 'w') as f:
    json.dump(docs, f)
print(f'exported {len(docs)} recipes')
"
```

---

## Step 4 — Train the projection head

```bash
python -m recipe_ml.training.main
```

Writes a checkpoint per epoch **and** `model/model.pt`, which is the file the API
and the embedding job both load.

> **Do this before Step 5.** The projection head starts out randomly initialised.
> If you embed the collection first and train afterwards, every stored vector was
> produced by different weights than the ones answering queries, and all
> similarity scores are meaningless. Nothing errors — the results are just wrong.

Takes ~10 epochs on CPU. Tune with `EPOCHS` / `BATCH_SIZE` in `.env`.

---

## Step 5 — Load, index and embed

```bash
python -m recipe_ml.scripts.load_recipes --wait
```

One command, three stages:

1. **upsert** — reads `data/recipes.json`, writes recipes into Mongo, keyed on
   `URL` so re-running updates instead of duplicating
2. **index** — creates the Atlas Vector Search index if it's missing
   (`--wait` blocks until it reports `READY`, usually a minute or two)
3. **embed** — embeds every recipe that doesn't have a vector yet

Ends with `N/N recipes are searchable`. Safe to re-run at any point — each stage
skips work that's already done.

If the recipes are already in Atlas and you only want vectors:

```bash
python -m recipe_ml.scripts.load_recipes --skip-load --wait
```

---

## Step 6 — Run the API

```bash
uvicorn recipe_ml.api.app:app --reload
```

Interactive docs at <http://127.0.0.1:8000/docs>.

```bash
curl localhost:8000/health
# {"status":"ok","database":"up","model_weights":"trained"}
```

Both `"database":"up"` and `"model_weights":"trained"` should be true before you
trust any result.

```bash
curl -X POST localhost:8000/recommend \
  -H 'Content-Type: application/json' \
  -d '{"ingredients":"tomato, garlic, onion, butter, cream, paneer","k":5}'
```

---

## Day-to-day

| I want to… | Run |
|---|---|
| Start the API | `uvicorn recipe_ml.api.app:app --reload` |
| Add new recipes from a file | `python -m recipe_ml.scripts.load_recipes --source path/to/new.json` |
| Embed recipes the Backend inserted | `python -m recipe_ml.scripts.load_recipes --skip-load` |
| Retrain | `python -m recipe_ml.training.main` **then** `--skip-load --overwrite` (below) |
| Re-embed everything after retraining | `python -m recipe_ml.scripts.load_recipes --skip-load --overwrite` |
| Embed one recipe on the fly | `POST /embed/{recipe_id}` |
| Wipe and start over | `python -m recipe_ml.scripts.load_recipes --drop` (asks first) |

**Retraining always means re-embedding.** New weights invalidate every stored vector.

---

## Deploy

```bash
docker build -t recipe-ml .
docker run -p 8080:8080 --env-file .env recipe-ml
```

`model/model.pt` is copied into the image, so **train before you build**. The
`training/` package is excluded from the image — serving doesn't need it.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `DatabaseError: MONGO_URI is not set` | empty/missing `.env` value | Step 2 |
| `connected: False` from the ping check | wrong URI, or IP not allow-listed in Atlas | Atlas → Network Access |
| `WARNING: no trained weights at model/model.pt` | never trained | Step 4 |
| `"model_weights":"untrained"` in `/health` | same | Step 4 |
| 503 `$vectorSearch stage is only allowed on MongoDB Atlas` | pointed at a local `mongod` | use the Atlas URI |
| 503 mentioning the index name | index missing or still building | `python -m recipe_ml.scripts.load_recipes --skip-load --wait` |
| `/recommend` returns `[]` | nothing embedded yet | Step 5 |
| Results look random | embedded before training | Step 4, then `--skip-load --overwrite` |
| `ModuleNotFoundError: recipe_ml` | `src/` not on the path | `uv sync`, or prefix with `PYTHONPATH=src` |
| `FileNotFoundError: no recipe file at …` | no corpus | Step 3, or pass `--source` |

---

## What lives where

```
.env             your secrets — never committed
data/            recipe corpus — gitignored
model/model.pt   trained weights — gitignored, needed to serve
src/recipe_ml/   the code (see README.md for the module map)
```

`.env`, `data/` and `model/` are all gitignored, so a fresh clone always needs
Steps 2–5 before it can serve.
