from config.config import Config
from .data_processor import DataProcessor
from .embedder import RecipeEmbeddingModel
from .trainer import Trainer

def train_model():
    config = Config()
    
    data_processor = DataProcessor(config)
    train_dataset, val_dataset = data_processor.load_and_preprocess_data()
    train_loader, val_loader = data_processor.create_dataloaders(train_dataset, val_dataset)
    
    model = RecipeEmbeddingModel(config)
    trainer = Trainer(model, config)

    train_losses, val_losses = trainer.train(train_loader, val_loader)
    
    
    return model, data_processor.df

def main():
    model, df = train_model()
    print("model trained")

if __name__ == "__main__":
    main()