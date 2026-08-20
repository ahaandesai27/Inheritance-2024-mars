import os
import torch
import numpy as np
import torch.nn.functional as F
from typing import List
from sentence_transformers import SentenceTransformer
from torch import nn

from ..config import Config

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
            nn.Linear(384, config.EMBEDDING_DIM), 
            nn.ReLU(),
            nn.Linear(config.EMBEDDING_DIM, config.EMBEDDING_DIM)
            #! for tasks like cosine similarity, important not to add a relu here
            #! as negative values are also important 
        )
        
    def forward(self, texts: List[str]):
        # Get BERT embeddings. SentenceTransformer.encode runs under
        # torch.inference_mode, and an inference tensor cannot be part of a
        # graph autograd will back-propagate through - cloning gives a normal
        # tensor. The transformer stays frozen either way; only the projection
        # head is trained.
        embeddings = self.transformer.encode(texts, convert_to_tensor=True).clone()
        # Projected embeddings
        projected = self.projection(embeddings)
        return projected

    def load_weights(self, path=None):
        """
        Load the trained projection head.
        Without this the projection is random, and a vector stored by the
        embedding job would not match a query vector made by the API.
        """
        path = str(path or self.config.MODEL_WEIGHTS_PATH)
        if not os.path.exists(path):
            print(f"WARNING: no trained weights at {path} - using a random projection. "
                  f"Stored embeddings and query embeddings will NOT match.")
            return self
        self.load_state_dict(torch.load(path, map_location="cpu"))
        self.eval()
        return self

    @torch.no_grad()
    def embed(self, texts: List[str]) -> np.ndarray:
        """
        Embed a batch of texts locally.
        Vectors are L2 normalised so cosine similarity is just a dot product.
        """
        embeddings = self.transformer.encode(texts, convert_to_tensor=True)
        projected = self.projection(embeddings)
        projected = F.normalize(projected, p=2, dim=1)
        return projected.cpu().numpy()
    
    def get_embedding(self, text: str) -> np.ndarray:
        # convert a given text to embedding - for recommendation purposes
        return self.embed([text])[0]
