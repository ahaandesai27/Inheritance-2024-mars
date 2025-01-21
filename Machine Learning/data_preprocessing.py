import pandas as pd
from sklearn.model_selection import train_test_split

def load_data(recipe_file, ingredient_file):
    recipes = pd.read_csv(recipe_file)
    ingredients = open(ingredient_file, 'r').readlines()
    recipes['Input'] = "Find similar recipes for: " + recipes['Ingredients']
    recipes['Output'] = recipes['Name'] + ": " + recipes['Ingredients']
    return train_test_split(recipes[['Input', 'Output']], test_size=0.2, random_state=42)
