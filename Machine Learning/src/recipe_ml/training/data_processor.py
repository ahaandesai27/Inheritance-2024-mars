from pathlib import Path

import pandas as pd
from sklearn.model_selection import train_test_split
from typing import Tuple, List
import torch
from torch.utils.data import Dataset, DataLoader
from ..config import Config

class RecipeDataset(Dataset):
    def __init__(self, texts: List[str]):
        self.texts = texts

    def __len__(self):
        return len(self.texts)

    def __getitem__(self, idx):
        item = {'text': self.texts[idx]}
        return item

"""
This class takes in as input the configuration parameters (config), which included where the JSON data was.
I've made a class config, which included static variables as parameters
An object of this class would allow access to these parameters.     

In the main training program, load_and_preprocess_data is called first.
This convers the json data to a pandas dataframe, on which some functions are applied
The Cleaned-ingredients field contained ingredients separated by comma, so first I converted them to a list of ingredients.
This was done so that we could get ingredients-text field, which is just space separated ingredients (for the embeddings).
And then cleaned-ingredients was again transformed back to comma separated ingredients (though this step isnt necessary)
Then this data is saved to a file, for embedding and querying purposes 

Later use of json file was changed to embeddings + direct database queries.

"""
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
        self.save_data(self.config.PROCESSED_DATA_PATH)  # Save after ingredients_text is created
        
        train_texts, val_texts = train_test_split(
            self.df['ingredients_text'].tolist(),
            train_size=self.config.TRAIN_SIZE,
            random_state=42
        )
        train_dataset = RecipeDataset(train_texts)
        val_dataset = RecipeDataset(val_texts)
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

    def save_data(self, file_path) -> None:
        Path(file_path).parent.mkdir(parents=True, exist_ok=True)
        self.df.to_json(file_path, orient='records', lines=True)  # Saving as JSON
        print(f"Data saved to {file_path}")