import torch
from transformers import T5ForConditionalGeneration, T5Tokenizer
from torch.utils.data import DataLoader

def train_model(train_data, tokenizer, model, epochs=3, batch_size=10):
    # Freeze the encoder layers
    for param in model.encoder.parameters():
        param.requires_grad = False  # Freeze encoder
    
    # Ensure decoder parameters are trainable
    for param in model.decoder.parameters():
        param.requires_grad = True

    # Freeze shared embeddings if needed (optional, can be left trainable if required)
    model.shared.requires_grad = False

    # DataLoader for batching
    train_loader = DataLoader(train_data, batch_size=batch_size, shuffle=True)

    # Optimizer
    optimizer = torch.optim.AdamW(filter(lambda p: p.requires_grad, model.parameters()), lr=5e-5)

    # Training loop
    model.train()
    for epoch in range(epochs):
        print(f"Entering epoch {epoch}")
        total_loss = 0  # Track loss for the epoch
        i = 0
        for batch in train_loader:
            print(f"Entering batch {i}")
            optimizer.zero_grad()
            outputs = model(input_ids=batch['input_ids'], labels=batch['target_ids'])
            loss = outputs.loss
            print("Computing backprop.")
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
            i += 1
            print("Batch done.")
        
        avg_loss = total_loss / len(train_loader)  # Average loss for the epoch
        print(f"Epoch {epoch+1}, Loss: {avg_loss:.4f}")

    return model
