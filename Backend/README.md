# Recipaura

The backend for recipaura

## Prerequisites

- **Node.js** (v14+ recommended) – [Download here](https://nodejs.org/)
- **npm** (comes with Node.js) or **yarn**

## Getting Started

1. **Clone the repository**

   ```bash
   git clone https://github.com/ahaandesai27/Inheritance-2024-mars.git
   cd Inheritance-2024-mars/Backend
   ```

2. **Install dependencies**

   Using npm:
   ```bash
   npm install
   ```

3. **Set up environment variables**

   - Create a `.env` file in the root of the project.
   - Add the following variables to configure your server (adjust values as needed):

     ```env
     DATABASE_URL=
     PORT=3500
     JWT_SECRET=
     ```

4. **Run the server**

   To start the server, run

   ```bash
   npm start
   ```


## API Documentation

## **Routes**

### **1. Recipe Routes**
**Base Path**: `/api/recipes`

### **Recipe Schema**
- **`TranslatedRecipeName`**: Name of the recipe (String, required).  
- **`TranslatedIngredients`**: Ingredients as a string (String, required).  
- **`TotalTimeInMins`**: Total time required to prepare the recipe (Number, required, minimum value: 1).  
- **`Cuisine`**: Cuisine type (String, required).  
- **`TranslatedInstructions`**: Instructions for preparation (String, required).  
- **`URL`**: URL to the recipe (String, optional).  
- **`Cleaned-Ingredients`**: Processed ingredient details (String, required).  
- **`image-url`**: URL to the recipe's image (String, required).  
- **`Ingredient-count`**: Number of ingredients used (Number, required, minimum value: 1).
- **`calorieCount`**: Calorie count of recipe
- **`veg`**: Boolean, true if veg dish else false 

#### **Endpoints**:
- **`GET ?skip={skip}&limit={limit}&cuisine={cuisine}`**  
  Fetch all recipes, skips by skip, limits by limit and checks for cuisine.

- **`POST `**  
  Create a new recipe.

- **`GET /:id`**  
  Fetch a recipe by its ID.

- **`PUT /:id`**  
  Update a recipe by its ID.

- **`DELETE /:id`**  
  Delete a recipe by its ID.

- **`GET /search?q={query}&skip={skip}&limit={limit}`**
  Searches for recipes based on the query, skip by 'skip' amount and limit by 'limit' amount
  Example: /search?q=paneer&skip=4&limit=10
  By default skip = 0 and limit = 10

- **`GET /autocomplete?q={query}&limit={limit}`**
Autocomplete for the searching 
Default limit 5

### **2. Ingredient Routes**
#### **Endpoints**:
- **`GET /api/ingredients?q={query}&skip={skip}&limit={limit}`**  
  Fetches all ingredients in a given category. Default limit 50.
  It will return **`name`**, **`category`**, **`_id`**


### **3. Getting ingredient prices from the stores**
The store clients live in `controllers/stores/`. Each one calls that store's own JSON API and
returns an array of products. They are plain functions, not routes yet:

```js
const bigBasketSearch = require('./controllers/stores/bigbasket');
const products = await bigBasketSearch('paneer', { limit: 30 });
```

Available: `controllers/stores/bigbasket.js`, `blinkit.js`, `dmart.js`, `starquik.js`.

#### **Response Keys**:
All four return the same shape, an array of objects with these keys:
- **`productName`**: Name of the product.
- **`productPrice`**: Object containing:
  - `discountedPrice`: Discounted or final price.
  - `originalPrice`: Original or marked price.
- **`productWeight`**: Weight of the product.
- **`productImage`**: URL to the product image.
- **`productLink`**: Link to the product page.
- **`brand`**: Brand name.
- **`inStock`**: Whether the store has it in stock.
- **`origin`**: Source platform (e.g., "bigbasket").

<br> **Note**: A field is `null` when the store does not provide it, but the key is
always there, so you can read it without checking first.

#### **Store notes**:
- **BigBasket** - fetches a session cookie from the homepage first, since the search
  call needs one. Rate limited, so it returns 429 if you hammer it.
- **Starquik** - capped at 10 results by the endpoint, and it has no paging.
- **DMart** - prices are per SKU, so one product can turn into several entries
  (200 g, 500 g, ...). `storeId` option picks the region, defaults to Mumbai.
- **Blinkit** - shells out to `curl` because the site needs HTTP/2, which Node's
  `fetch` cannot do. **`curl` has to be installed on the machine.**

## Troubleshooting

- If the server doesn't start, make sure Node.js and npm are correctly installed and that all dependencies are installed.
- Check that your `.env` file has the correct configuration.
- or create an issue on github.
