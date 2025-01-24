import torch
from transformers import T5ForConditionalGeneration, T5Tokenizer
from torch.utils.data import DataLoader

def train_model(train_data, tokenizer, model, epochs=3, batch_size=4):
    train_loader = DataLoader(train_data, batch_size=batch_size, shuffle=True)
    optimizer = torch.optim.AdamW(model.parameters(), lr=5e-5)

    model.train()
    for epoch in range(epochs):
        for batch in train_loader:
            optimizer.zero_grad()
            outputs = model(input_ids=batch['input_ids'], labels=batch['target_ids'])
            loss = outputs.loss
            loss.backward()
            optimizer.step()
        print(f"Epoch {epoch+1}, Loss: {loss.item()}")

    return model
