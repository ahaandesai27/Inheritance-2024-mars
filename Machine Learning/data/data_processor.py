import pandas as pd
from sklearn.model_selection import train_test_split
from typing import Tuple, List
import torch
from torch.utils.data import Dataset, DataLoader
from config.config import Config

class RecipeDataset(Dataset):
    def __init__(self, texts: List[str], labels: List[Tuple[str, int]] = None):
        self.texts = texts
        self.labels = labels

    def __len__(self):
        return len(self.texts)

    def __getitem__(self, idx):
        item = {'text': self.texts[idx]}
        if self.labels is not None:
            item['label'] = self.labels[idx]
        return item

class DataProcessor:
    def __init__(self, config: Config):
        self.config = config
        self.df = None
    
    def clean_ingredients(self, ingredients_str: str) -> List[str]:
        if pd.isna(ingredients_str):
            return []
        ingredients = [ing.strip() for ing in ingredients_str.split(',') if ing.strip()]
        return ingredients
        
    def load_and_preprocess_data(self) -> Tuple[RecipeDataset, RecipeDataset]:
        self.df = pd.read_json(self.config.DATA_PATH)  # Reading data from a JSON file
        self.df['Cleaned-Ingredients'] = self.df['Cleaned-Ingredients'].apply(self.clean_ingredients)
        self.df['ingredients_text'] = self.df['Cleaned-Ingredients'].apply(lambda x: ' '.join(x))
        self.df['Cleaned-Ingredients'] = self.df['Cleaned-Ingredients'].apply(lambda x: ', '.join(x))
        self.save_data('./recipes.json')  # Save after ingredients_text is created
        
        cuisines = self.df['Cuisine'].tolist()
        total_time = self.df['TotalTimeInMins'].tolist()
        calorie_count = self.df['calorieCount'].tolist()
        
        labels = list(zip(cuisines, total_time, calorie_count))
        train_texts, val_texts, train_labels, val_labels = train_test_split(
            self.df['ingredients_text'].tolist(),
            labels,
            train_size=self.config.TRAIN_SIZE,
            random_state=42
        )
        train_dataset = RecipeDataset(train_texts, train_labels)
        val_dataset = RecipeDataset(val_texts, val_labels)
        return train_dataset, val_dataset
    
    def create_dataloaders(self, train_dataset: RecipeDataset, 
                          val_dataset: RecipeDataset) -> Tuple[DataLoader, DataLoader]:
        train_loader = DataLoader(
            train_dataset,
            batch_size=self.config.BATCH_SIZE,
            shuffle=True
        )
        val_loader = DataLoader(
            val_dataset,
            batch_size=self.config.BATCH_SIZE,
            shuffle=False
        )
        return train_loader, val_loader

    def save_data(self, file_path: str) -> None:
        self.df.to_json(file_path, orient='records', lines=True)  # Saving as JSON
        print(f"Data saved to {file_path}")
