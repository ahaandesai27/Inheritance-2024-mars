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
- **`translatedRecipeName`**: Name of the recipe (String, required).  
- **`translatedIngredients`**: Ingredients as a string (String, required).  
- **`totalTimeInMins`**: Total time required to prepare the recipe (Number, required, minimum value: 1).  
- **`cuisine`**: Cuisine type (String, required).  
- **`translatedInstructions`**: Instructions for preparation (String, required).  
- **`url`**: URL to the recipe (String, optional).  
- **`cleanedIngredients`**: Processed ingredient details (String, required).  
- **`imageUrl`**: URL to the recipe's image (String, required).  
- **`ingredientCount`**: Number of ingredients used (Number, required, minimum value: 1).

#### **Endpoints**:
- **`GET /`**  
  Fetch all recipes.

- **`POST /`**  
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

### **2. Ingredient Categories Routes**
**Base Path**: `/api/ingredients`

These routes manage ingredient categories and subcategories.

#### **Endpoints**:
- **`POST /`**  
  Create a new category.

- **`GET /`**  
  Fetch all categories.

- **`GET /:id`**  
  Fetch a category by its ID.

- **`PUT /:id`**  
  Update a category by its ID.

- **`DELETE /:id`**  
  Delete a category by its ID.


### **Category Schema**

#### **Category Fields**:
- **`category`**: Name of the category (String, required, unique).  
- **`subcategories`**: Array of subcategory objects.

#### **Subcategory Fields**:
- **`name`**: Name of the subcategory (String, required).  
- **`ingredients`**: Array of ingredient objects.

#### **Ingredient Fields**:
- **`name`**: Name of the ingredient (String).  
- **`nutritionalInfo`**: Object containing:
  - `calories`: Number of calories.
  - `protein`: Protein content.
  - `fat`: Fat content.
  - `carbohydrates`: Carbohydrate content.  

### **3. Routes for getting ingredient prices and other data from crawlers**
**Base Path**: `/api/getingredients/<platform>?q=<item>`<br>
**Example**: `/api/getingredients/amazon?q=bananas`

#### **Crawler Response Keys**:
Each crawler returns an array of objects with the following keys:
- **`productName`**: Name of the product.  
- **`productPrice`**: Object containing:
  - `discountedPrice`: Discounted or final price.
  - `originalPrice`: Original or marked price (if available).  
- **`productWeight`**: Weight of the product.  
- **`productImage`**: URL to the product image.  
- **`productLink`**: Link to the product page.  
- **`origin`**: Source platform (e.g., "amazon").
<br> **Note**: Some crawlers may return less information than mentioned above.

#### **Endpoints**:
- **`GET /amazon`**  
  Fetches ingredients data from Amazon.

- **`GET /zepto`**  
  Fetches ingredients data from Zepto.

- **`GET /swiggy`**  
  Fetches ingredients data from Swiggy. 
  <br>[**Note**: `productLink` not available yet]

- **`GET /bigbasket`**  
  Fetches ingredients data from BigBasket.
  <br>[**Note**: `productImage` not available yet]

[**Note**: the following routes need fixing.]
- **`GET /blinkit`**  
  Fetches ingredients data from Blinkit.



## Troubleshooting

- If the server doesn't start, make sure Node.js and npm are correctly installed and that all dependencies are installed.
- Check that your `.env` file has the correct configuration.
- or create an issue on github.
