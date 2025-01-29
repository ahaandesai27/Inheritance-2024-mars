from config.config import Config
from data.data_processor import DataProcessor
from models.model import RecipeEmbeddingModel, RecipeRecommender
from models.trainer import Trainer
from utils.utils import plot_training_curves, load_trained_model

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
    recommender = RecipeRecommender(model, df)
    
    # query_ingredients = "paneer tomatoes"
    # recommendations = recommender.find_similar_recipes(query_ingredients, n_recommendations=5)
    
    # print("\nRecommendations based on ingredients:")
    # for recipe_name, score in recommendations:
    #     print(f"{recipe_name}: {score:.4f}")

if __name__ == "__main__":
    main()