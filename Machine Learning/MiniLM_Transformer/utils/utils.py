import matplotlib.pyplot as plt
from typing import List
import torch

def plot_training_curves(train_losses: List[float], val_losses: List[float]):
    plt.figure(figsize=(10, 6))
    plt.plot(train_losses, label='Train Loss')
    plt.plot(val_losses, label='Validation Loss')
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.title('Training and Validation Losses')
    plt.legend()
    plt.show()

def load_trained_model(model, model_path: str):
    model.load_state_dict(torch.load(model_path))
    return model