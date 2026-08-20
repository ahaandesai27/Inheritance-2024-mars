import os
from pathlib import Path

from dotenv import load_dotenv


def _project_root() -> Path:
    # .../Machine Learning/src/recipe_ml/config.py -> .../Machine Learning.
    # Only valid for a checkout or editable install, hence the marker check.
    candidate = Path(__file__).resolve().parents[2]
    if (candidate / "pyproject.toml").exists():
        return candidate
    return Path.cwd()


PROJECT_ROOT = _project_root()

# real environment variables win over the file
load_dotenv(PROJECT_ROOT / ".env")


def _env_path(name: str, default: Path) -> Path:
    value = os.getenv(name)
    return Path(value).expanduser() if value else default


class Config:
    PROJECT_ROOT = PROJECT_ROOT

    # --- Data ---------------------------------------------------------------
    DATA_PATH = _env_path("DATA_PATH", PROJECT_ROOT / "data" / "recipes.json")
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
    # The embedding job and the API must load the same file, or the two
    # projections differ and the stored vectors mean nothing.
    MODEL_WEIGHTS_PATH = _env_path("MODEL_WEIGHTS_PATH", MODEL_SAVE_PATH / "model.pt")

    # --- MongoDB / Atlas Vector Search --------------------------------------
    MONGO_URI = os.getenv("MONGO_URI")
    MONGO_DB = os.getenv("MONGO_DB", "RecipAura")
    RECIPE_COLLECTION = os.getenv("RECIPE_COLLECTION", "recipes")
    EMBEDDING_FIELD = "embedding"
    VECTOR_INDEX_NAME = os.getenv("VECTOR_INDEX_NAME", "recipe_vector_index")
    VECTOR_SIMILARITY = "cosine"
    # candidates Atlas scans per query; higher = more accurate, slower
    NUM_CANDIDATES_MULTIPLIER = int(os.getenv("NUM_CANDIDATES_MULTIPLIER", 10))

    # --- Server -------------------------------------------------------------
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", 8080))

    def ensure_dirs(self) -> None:
        """Called explicitly so importing the config never touches the disk."""
        self.MODEL_SAVE_PATH.mkdir(parents=True, exist_ok=True)
