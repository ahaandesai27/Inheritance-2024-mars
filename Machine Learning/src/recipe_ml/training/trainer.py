from typing import Tuple

import torch
import torch.nn.functional as F
from torch import nn
from torch.utils.data import DataLoader
from tqdm import tqdm

from ..config import Config
from ..model.embedder import RecipeEmbeddingModel


class ContrastiveLoss(nn.Module):
    def __init__(self, temperature=0.07):
        super().__init__()
        self.temperature = temperature

    def forward(self, embeddings):
        embeddings = F.normalize(embeddings, p=2, dim=1)
        similarity_matrix = torch.matmul(embeddings, embeddings.T)
        logits = similarity_matrix / self.temperature
        labels = torch.arange(logits.shape[0], device=logits.device)
        return F.cross_entropy(logits, labels)


class Trainer:
    """Trains the projection head with AdamW."""

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
            embeddings = self.model(batch['text'])
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
                embeddings = self.model(batch['text'])
                total_loss += self.criterion(embeddings).item()

        return total_loss / len(val_loader)

    def train(self, train_loader: DataLoader,
              val_loader: DataLoader) -> Tuple[list, list]:
        train_losses = []
        val_losses = []

        for epoch in range(self.config.EPOCHS):
            print(f"\nEpoch {epoch+1}/{self.config.EPOCHS}")

            train_loss = self.train_epoch(train_loader)
            train_losses.append(train_loss)

            val_loss = self.validate(val_loader)
            val_losses.append(val_loss)

            print(f"Train Loss: {train_loss:.4f}")
            print(f"Val Loss: {val_loss:.4f}")

            # checkpoint per epoch so a crash does not lose the whole run
            self.save(self.config.MODEL_SAVE_PATH / f"model_epoch_{epoch+1}.pt")

        # the canonical path the embedding job and the API both load
        self.save(self.config.MODEL_WEIGHTS_PATH)

        return train_losses, val_losses

    def save(self, path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        torch.save(self.model.state_dict(), path)
        print(f"saved weights to {path}")
