import torch
import numpy as np
from typing import List
from sentence_transformers import SentenceTransformer
from torch import nn

from ..config.config import Config

class RecipeEmbeddingModel(nn.Module):
    """
    This is a neural network that builds on the all miniLM sentence "transformer"
    We added a 2 more blocks as a projection to compute the final embeddings
    """
    def __init__(self, config: Config):
        super().__init__()
        self.config = config
        self.transformer = SentenceTransformer(config.BASE_MODEL, device='cpu')
        self.device = "cpu"

        """
        sentence transformer returned a 384 embedded vector
        to decrease embedding size to 256 -> less memory better performance
        added 2 more blocks and an relu for non linearity
        """
        
        self.projection = nn.Sequential(
            nn.Linear(384, 256), 
            nn.ReLU(),
            nn.Linear(256, 256)
            #! for tasks like cosine similarity, important not to add a relu here
            #! as negative values are also important 
        )
        
    def forward(self, texts: List[str]):
        # Get BERT embeddings
        embeddings = self.transformer.encode(texts, convert_to_tensor=True)
        # Projected embeddings
        projected = self.projection(embeddings)
        return projected
    
    def get_embedding(self, text: str) -> np.ndarray:
        # convert a given text to embedding - for recommendation purposes
        with torch.no_grad():
            embedding = self.transformer.encode([text], convert_to_tensor=True)
            projected = self.projection(embedding)
            return projected.cpu().numpy()[0]
            # some libraries only work on cpu tensors so its necessary to convert 
            # operations only work on tensors on teh same device