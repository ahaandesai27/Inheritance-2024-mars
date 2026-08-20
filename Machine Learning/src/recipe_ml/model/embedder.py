import os
from typing import List

import numpy as np
import torch
import torch.nn.functional as F
from sentence_transformers import SentenceTransformer
from torch import nn

from ..config import Config


class RecipeEmbeddingModel(nn.Module):
    """MiniLM sentence encoder (frozen) plus a trained projection head."""

    def __init__(self, config: Config):
        super().__init__()
        self.config = config
        self.transformer = SentenceTransformer(config.BASE_MODEL, device='cpu')
        self.device = "cpu"

        # 384 -> EMBEDDING_DIM. No ReLU on the last layer: cosine similarity needs the negative components too.
        self.projection = nn.Sequential(
            nn.Linear(384, config.EMBEDDING_DIM),
            nn.ReLU(),
            nn.Linear(config.EMBEDDING_DIM, config.EMBEDDING_DIM)
        )

    def forward(self, texts: List[str]):
        embeddings = self.transformer.encode(texts, convert_to_tensor=True).clone()
        return self.projection(embeddings)

    def load_weights(self, path=None):
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
        embeddings = self.transformer.encode(texts, convert_to_tensor=True)
        projected = self.projection(embeddings)
        projected = F.normalize(projected, p=2, dim=1)
        return projected.cpu().numpy()

    def get_embedding(self, text: str) -> np.ndarray:
        return self.embed([text])[0]
