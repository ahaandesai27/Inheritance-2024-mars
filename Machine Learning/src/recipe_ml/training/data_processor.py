from pathlib import Path
from typing import List, Tuple

import pandas as pd
from sklearn.model_selection import train_test_split
from torch.utils.data import DataLoader, Dataset

from ..config import Config


class RecipeDataset(Dataset):
    def __init__(self, texts: List[str]):
        self.texts = texts

    def __len__(self):
        return len(self.texts)

    def __getitem__(self, idx):
        return {'text': self.texts[idx]}


class DataProcessor:
    def __init__(self, config: Config):
        self.config = config
        self.df = None

    def clean_ingredients(self, ingredients_str: str) -> List[str]:
        if pd.isna(ingredients_str):
            return []
        return [ing.strip() for ing in ingredients_str.split(',') if ing.strip()]

    def load_and_preprocess_data(self) -> Tuple[RecipeDataset, RecipeDataset]:
        self.df = pd.read_json(self.config.DATA_PATH)
        self.df['Cleaned-Ingredients'] = self.df['Cleaned-Ingredients'].apply(self.clean_ingredients)
        self.df['ingredients_text'] = self.df['Cleaned-Ingredients'].apply(lambda x: ' '.join(x))
        self.df['Cleaned-Ingredients'] = self.df['Cleaned-Ingredients'].apply(lambda x: ', '.join(x))
        self.save_data(self.config.PROCESSED_DATA_PATH)

        train_texts, val_texts = train_test_split(
            self.df['ingredients_text'].tolist(),
            train_size=self.config.TRAIN_SIZE,
            random_state=42
        )
        return RecipeDataset(train_texts), RecipeDataset(val_texts)

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

    def save_data(self, file_path) -> None:
        Path(file_path).parent.mkdir(parents=True, exist_ok=True)
        self.df.to_json(file_path, orient='records', lines=True)
        print(f"Data saved to {file_path}")
