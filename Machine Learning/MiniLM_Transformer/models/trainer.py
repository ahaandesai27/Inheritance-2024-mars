import torch
from torch import nn
import torch.nn.functional as F
from tqdm import tqdm
from typing import Tuple
from torch.utils.data import DataLoader
from config.config import Config
from .model import RecipeEmbeddingModel

class ContrastiveLoss(nn.Module):
    def __init__(self, temperature=0.07):
        super().__init__()
        self.temperature = temperature
        
    def forward(self, embeddings):
        embeddings = F.normalize(embeddings, p=2, dim=1)
        similarity_matrix = torch.matmul(embeddings, embeddings.T)
        logits = similarity_matrix / self.temperature
        labels = torch.arange(logits.shape[0], device=logits.device)
        loss = F.cross_entropy(logits, labels)
        
        return loss

class Trainer:
    def __init__(self, model: RecipeEmbeddingModel, config: Config):
        self.model = model
        self.config = config
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.model.to(self.device)
        
        self.optimizer = torch.optim.AdamW(
            self.model.parameters(),
            lr=config.LEARNING_RATE,
            weight_decay=config.WEIGHT_DECAY
        )
        
        self.criterion = ContrastiveLoss()
        
    def train_epoch(self, train_loader: DataLoader) -> float:
        self.model.train()
        total_loss = 0
        
        for batch in tqdm(train_loader, desc="Training"):
            texts = batch['text']
            embeddings = self.model(texts)
            loss = self.criterion(embeddings)
            if torch.isnan(loss):
                print("Warning: NaN loss detected!")
                continue
            
            self.optimizer.zero_grad()
            loss.backward()
            torch.nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
            self.optimizer.step()
            
            total_loss += loss.item()
            
        return total_loss / len(train_loader)
    
    def validate(self, val_loader: DataLoader) -> float:
        self.model.eval()
        total_loss = 0
        
        with torch.no_grad():
            for batch in tqdm(val_loader, desc="Validation"):
                texts = batch['text']
                embeddings = self.model(texts)
                loss = self.criterion(embeddings)
                total_loss += loss.item()
                
        return total_loss / len(val_loader)
    
    def train(self, train_loader: DataLoader, 
              val_loader: DataLoader) -> Tuple[list, list]:
        train_losses = []
        val_losses = []
        
        for epoch in range(self.config.EPOCHS):
            print(f"\nEpoch {epoch+1}/{self.config.EPOCHS}")
            
            # Training
            train_loss = self.train_epoch(train_loader)
            train_losses.append(train_loss)
            
            # Validation
            val_loss = self.validate(val_loader)
            val_losses.append(val_loss)
            
            print(f"Train Loss: {train_loss:.4f}")
            print(f"Val Loss: {val_loss:.4f}")
            
            # Save model
        model_path = self.config.MODEL_SAVE_PATH / f"model_epoch_{epoch+1}.pt"
        torch.save(self.model.state_dict(), model_path)
            
        return train_losses, val_losses