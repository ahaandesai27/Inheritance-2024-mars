def recommend_recipes(input_ingredients, tokenizer, model):
    input_text = f"Find similar recipes for: {input_ingredients}"
    input_ids = tokenizer(input_text, return_tensors="pt").input_ids

    outputs = model.generate(input_ids, max_length=50, num_return_sequences=3, num_beams=5)
    return [tokenizer.decode(output, skip_special_tokens=True) for output in outputs]
