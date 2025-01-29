from pathlib import Path

class Config:
    # Data parameters
    DATA_PATH = "recipes.csv"
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
    ROOT_DIR = Path(__file__).parent.parent
    MODEL_SAVE_PATH = ROOT_DIR / "saved_models"
    
    # Create directories if they don't exist
    MODEL_SAVE_PATH.mkdir(parents=True, exist_ok=True)