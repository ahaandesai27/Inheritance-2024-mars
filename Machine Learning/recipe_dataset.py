import torch
from torch.utils.data import Dataset

class RecipeDataset(Dataset):
    def __init__(self, dataframe, tokenizer, max_length=128):
        self.data = dataframe
        self.tokenizer = tokenizer
        self.max_length = max_length

    def __len__(self):
        return len(self.data)

    def __getitem__(self, index):
        input_text = self.data.iloc[index]['Input']
        target_text = self.data.iloc[index]['Output']

        input_ids = self.tokenizer(input_text, truncation=True, padding="max_length", max_length=self.max_length).input_ids
        target_ids = self.tokenizer(target_text, truncation=True, padding="max_length", max_length=self.max_length).input_ids

        return {
            "input_ids": torch.tensor(input_ids, dtype=torch.long),
            "target_ids": torch.tensor(target_ids, dtype=torch.long),
        }
