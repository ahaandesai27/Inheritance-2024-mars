import torch
import numpy as np
from typing import List
from sentence_transformers import SentenceTransformer
from torch import nn

from ..config.config import Config

class RecipeEmbeddingModel(nn.Module):
    def __init__(self, config: Config):
        super().__init__()
        self.config = config
        self.transformer = SentenceTransformer(config.BASE_MODEL, device='cpu')
        self.device = "cpu"
        
        self.projection = nn.Sequential(
            nn.Linear(384, 256), 
            nn.ReLU(),
            nn.Linear(256, 256)
        )
        
    def forward(self, texts: List[str]):
        # Get BERT embeddings
        embeddings = self.transformer.encode(texts, convert_to_tensor=True)
        # Project embeddings
        projected = self.projection(embeddings)
        return projected
    
    def get_embedding(self, text: str) -> np.ndarray:
        with torch.no_grad():
            embedding = self.transformer.encode([text], convert_to_tensor=True)
            projected = self.projection(embedding)
            return projected.cpu().numpy()[0]