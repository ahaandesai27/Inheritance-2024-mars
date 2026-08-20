"""
Central configuration.

Everything that differs between a laptop, a Colab notebook and the deployed
container is read from the environment, with a sane default for local runs.
Paths are resolved against the project root rather than the current working
directory, so a script behaves the same wherever it is launched from.
"""

import os
from pathlib import Path

from dotenv import load_dotenv

def _project_root() -> Path:
    """
    .../Machine Learning/src/recipe_ml/config.py -> .../Machine Learning

    That walk is only meaningful for a source checkout or an editable install.
    Installed as a plain wheel it would point into site-packages, so fall back
    to the working directory when the marker file is not there.
    """
    candidate = Path(__file__).resolve().parents[2]
    if (candidate / "pyproject.toml").exists():
        return candidate
    return Path.cwd()


PROJECT_ROOT = _project_root()

# Anchored to the project root so a script run from any directory - or from a
# Colab notebook - picks up the same .env. Real environment variables win.
load_dotenv(PROJECT_ROOT / ".env")


def _env_path(name: str, default: Path) -> Path:
    value = os.getenv(name)
    return Path(value).expanduser() if value else default


class Config:
    PROJECT_ROOT = PROJECT_ROOT

    # --- Data ---------------------------------------------------------------
    # Source corpus used for training and for the initial database load.
    DATA_PATH = _env_path("DATA_PATH", PROJECT_ROOT / "data" / "recipes.json")
    # Where the training run writes the cleaned corpus (adds `ingredients_text`).
    PROCESSED_DATA_PATH = _env_path("PROCESSED_DATA_PATH", PROJECT_ROOT / "data" / "recipes_processed.json")
    TRAIN_SIZE = 0.8

    # --- Model --------------------------------------------------------------
    BASE_MODEL = os.getenv("BASE_MODEL", "all-MiniLM-L6-v2")
    MAX_LENGTH = 512
    BATCH_SIZE = int(os.getenv("BATCH_SIZE", 32))
    EMBEDDING_DIM = int(os.getenv("EMBEDDING_DIM", 256))  # output of the projection head

    # --- Training -----------------------------------------------------------
    EPOCHS = int(os.getenv("EPOCHS", 10))
    LEARNING_RATE = 2e-5
    WARMUP_STEPS = 100
    WEIGHT_DECAY = 0.01

    # --- Paths --------------------------------------------------------------
    MODEL_SAVE_PATH = _env_path("MODEL_SAVE_PATH", PROJECT_ROOT / "model")
    # Weights of the trained projection head. Both the embedding job and the API
    # must load the same file, otherwise the projection is randomly initialised
    # differently in each process and the stored vectors become meaningless.
    MODEL_WEIGHTS_PATH = _env_path("MODEL_WEIGHTS_PATH", MODEL_SAVE_PATH / "model.pt")

    # --- MongoDB / Atlas Vector Search --------------------------------------
    MONGO_URI = os.getenv("MONGO_URI")
    MONGO_DB = os.getenv("MONGO_DB", "RecipAura")
    RECIPE_COLLECTION = os.getenv("RECIPE_COLLECTION", "recipes")
    EMBEDDING_FIELD = "embedding"
    VECTOR_INDEX_NAME = os.getenv("VECTOR_INDEX_NAME", "recipe_vector_index")
    VECTOR_SIMILARITY = "cosine"
    # ANN knob: how many candidates Atlas scans per query (higher = more
    # accurate, slower). Atlas recommends ~10-20x the number of results.
    NUM_CANDIDATES_MULTIPLIER = int(os.getenv("NUM_CANDIDATES_MULTIPLIER", 10))

    # --- Server -------------------------------------------------------------
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", 8080))

    def ensure_dirs(self) -> None:
        """Create the writable directories the app expects. Called explicitly
        so that merely importing the config never touches the filesystem."""
        self.MODEL_SAVE_PATH.mkdir(parents=True, exist_ok=True)
