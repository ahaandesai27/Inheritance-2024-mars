from transformers import T5Tokenizer, T5ForConditionalGeneration
from data_preprocessing import load_data
from recipe_dataset import RecipeDataset
from train_model import train_model
from inference import recommend_recipes
import sentencepiece 

# Load data
train_data, test_data = load_data("./Cleaned_Indian_Food_Dataset.csv", "./processed_ingredients.txt")

# Load model and tokenizer
model_name = "t5-small"
tokenizer = T5Tokenizer.from_pretrained(model_name, legacy=False)
model = T5ForConditionalGeneration.from_pretrained(model_name)

# Fine-tune model (optional)
train_dataset = RecipeDataset(train_data, tokenizer)
print("Training model...")
model = train_model(train_dataset, tokenizer, model)

# Save model
model.save_pretrained("recipe_recommendation_model")
tokenizer.save_pretrained("recipe_recommendation_model")

# Test inference
input_ingredients = "chicken, garlic, onion"
recommendations = recommend_recipes(input_ingredients, tokenizer, model)
print("Recommended Recipes:", recommendations)
print("Script completed successfully!")

