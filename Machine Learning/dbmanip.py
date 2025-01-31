import json

data = json.load(open('./recipes.json'))
for item in data:
    item['_id'] = item['_id']['$oid']

with open('./recipes.json', 'w') as f:
    json.dump(data, f, indent=4)
    
    