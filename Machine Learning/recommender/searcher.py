import numpy as np
import faiss
import json
import glob

from ..training.embedder import RecipeEmbeddingModel
        
class RecipeSearcher:
    def __init__(self, model: RecipeEmbeddingModel):
        self.model = model
        self.embeddings = self.load_all_embeddings()
        faiss.normalize_L2(self.embeddings)

        with open("./embeddings/metadata.json") as f:
            self.metadata = json.load(f)

        self.index = faiss.IndexFlatIP(self.embeddings.shape[1])
        self.index.add(self.embeddings)

    def load_all_embeddings(self):
        paths = sorted(glob.glob("./embeddings/batch_*.npy"))
        all_embs = [np.load(p) for p in paths]
        return np.vstack(all_embs)

    def search(self, query: str, top_k: int = 5):
        query_vec = self.model.get_embedding(query).astype('float32').reshape(1, -1)
        faiss.normalize_L2(query_vec)
        scores, indices = self.index.search(query_vec, top_k)

        results = []
        for idx, score in zip(indices[0], scores[0]):
            item = self.metadata[idx]
            item['similarity'] = float(score)
            results.append(item)
        return results