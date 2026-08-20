from ..config import Config
from ..model.embedder import RecipeEmbeddingModel
from .data_processor import DataProcessor
from .trainer import Trainer


def train_model():
    config = Config()
    config.ensure_dirs()

    data_processor = DataProcessor(config)
    train_dataset, val_dataset = data_processor.load_and_preprocess_data()
    train_loader, val_loader = data_processor.create_dataloaders(train_dataset, val_dataset)

    model = RecipeEmbeddingModel(config)
    trainer = Trainer(model, config)

    train_losses, val_losses = trainer.train(train_loader, val_loader)

    return model, data_processor.df


def main():
    model, df = train_model()
    print(f"model trained on {len(df)} recipes")


if __name__ == "__main__":
    main()
