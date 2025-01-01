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
      DATABASE_URI = 
      PORT = 4000
      ACCESS_TOKEN_SECRET = 
      OAUTH2_CLIENT_ID = 
      OAUTH2_CLIENT_SECRET = 
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

- **`GET /autocomplete?q={query}**`
  Gives recipe title suggestion based on keyword. 5 suggestions

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

### **4. Routes for Diet Plan management**
 There are two sets of routes 
 1) `/api/user/dietplans` - for managing diet plans of a user
 2) `/api/dietplans` - for managing recipes within a diet plan
 
 ####  Base `/api/user/dietplans`
 Note: before all these requests base url must be added.
- **`POST /:userId`**  
  Creates a new diet plan for a user. Specify the user ID in the request parameters, and the diet plan **name** and **description** in the request body.

- **`GET /:userId`**  
  Fetches all diet plans for a user.

- **`PUT /:dietPlanId`**  
  Edits an existing diet plan.

- **`DELETE /:userId/:dietPlanId`**  
  Deletes a diet plan for a user, specify user Id and corresponding diet plan Id.

 
#### Base `/api/dietplans/`

- **`POST /:dietPlanId/recipes/:recipeId`**  
  Adds a recipe to a diet plan.

- **`DELETE /:dietPlanId/recipes/:recipeId`**  
  Removes a recipe from a diet plan.

- **`GET /:dietPlanId/recipes`**  
  Retrieves all recipes in a diet plan.

### **5. User routes** 

- **`POST /register`
    Registers a user. Fields needed:
    i) For normal registration - firstName, lastName, username, password, email, mobileNumber
    ii) For google registration - firstName, lastName, username, email, googleId. After google verification on the frontend call a request on this route.
    All fields must be specified in the request body.

- **`POST /login`
    Logs in a user, this will return the JWT token, use that to authenticate user on client side.
 
- **`POST /auth/google` - Backend alternative for google auth, use only if frontend doesnt work

- **`GET /api/user/id/:userId` - fetches user using its user ID.
- 
- **`GET /api/user/:username` - fetches user using its username
    Example: /api/user/ahaandesai27

### **6. User recipe routes**
Base Path: `/api/user/recipes`

#### Endpoints:
POST `/saved`
Save a recipe for the user.

DELETE `/saved`
Delete a saved recipe for the user.

GET `/saved/:userId`
Get all saved recipes for a user.

POST `/history`
Add a recipe to the user's history.

GET `/history/:userId`
Get the history of recipes for a user.
 
Note: in the POST and DELETE requests, the fields "userId" and "recipeId" will need to be specified in the request body.



## Troubleshooting

- If the server doesn't start, make sure Node.js and npm are correctly installed and that all dependencies are installed.
- Check that your `.env` file has the correct configuration.
- or create an issue on github.
