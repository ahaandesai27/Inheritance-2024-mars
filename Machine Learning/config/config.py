from pathlib import Path

class Config:
    # Data parameters
    DATA_PATH = "/content/drive/My Drive/RecipeML/recipes.json"  # or adjust as needed
    TRAIN_SIZE = 0.8

    # Model parameters
    BASE_MODEL = "all-MiniLM-L6-v2"
    MAX_LENGTH = 512
    BATCH_SIZE = 32

    # Training parameters
    EPOCHS = 10
    LEARNING_RATE = 2e-5
    WARMUP_STEPS = 100
    WEIGHT_DECAY = 0.01

    # Paths
    DRIVE_ROOT = Path(".")
    MODEL_SAVE_PATH = DRIVE_ROOT / "model"

    # Ensure directory exists
    MODEL_SAVE_PATH.mkdir(parents=True, exist_ok=True)