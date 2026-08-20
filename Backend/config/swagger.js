// OpenAPI spec for the whole backend. Served by swagger-ui-express at /api-docs.
// Keep this in sync when you add or change a route.

const Recipe = {
  type: 'object',
  properties: {
    _id: { type: 'string', example: '6754a1b2c3d4e5f6a7b8c9d0' },
    TranslatedRecipeName: { type: 'string', example: 'Paneer Butter Masala' },
    TranslatedIngredients: { type: 'string' },
    TotalTimeInMins: { type: 'number', example: 45 },
    Cuisine: { type: 'string', example: 'Indian' },
    TranslatedInstructions: { type: 'array', items: { type: 'string' } },
    URL: { type: 'string' },
    'Cleaned-Ingredients': { type: 'string' },
    'image-url': { type: 'string' },
    'Ingredient-count': { type: 'number', example: 12 },
    calorieCount: { type: 'number', example: 350 },
    veg: { type: 'boolean', nullable: true },
  },
};

const DietPlan = {
  type: 'object',
  properties: {
    _id: { type: 'string' },
    name: { type: 'string', example: 'High protein week' },
    description: { type: 'string' },
    recipes: { type: 'array', items: { type: 'string' }, description: 'Recipe ids' },
    image: { type: 'string' },
    user: { type: 'string', description: 'User id' },
    totalCalorieCount: { type: 'number', example: 1800 },
    createdAt: { type: 'string', format: 'date-time' },
  },
};

const User = {
  type: 'object',
  properties: {
    _id: { type: 'string' },
    username: { type: 'string', example: 'ahaan' },
    firstName: { type: 'string' },
    lastName: { type: 'string' },
    email: { type: 'string', example: 'ahaan@example.com' },
    mobileNumber: { type: 'string', nullable: true },
    googleId: { type: 'string', nullable: true },
    savedRecipes: { type: 'array', items: { type: 'string' } },
    history: { type: 'array', items: { type: 'string' } },
    dietPlans: { type: 'array', items: { type: 'string' } },
    allergies: { type: 'array', items: { type: 'string' } },
    veg: { type: 'boolean', nullable: true },
    createdAt: { type: 'string', format: 'date-time' },
  },
};

const Ingredient = {
  type: 'object',
  properties: {
    _id: { type: 'string' },
    name: { type: 'string', example: 'Paneer' },
    category: { type: 'string', example: 'Dairy' },
  },
};

const Feedback = {
  type: 'object',
  properties: {
    _id: { type: 'string' },
    title: { type: 'string', maxLength: 100 },
    description: { type: 'string', maxLength: 1000 },
    user: { type: 'string', description: 'User id' },
    date: { type: 'string', format: 'date-time' },
  },
};

const StoreProduct = {
  type: 'object',
  description: 'Normalized across all four stores - fields a store does not provide are null.',
  properties: {
    productName: { type: 'string', nullable: true, example: 'Amul Malai Paneer' },
    productPrice: {
      type: 'object',
      properties: {
        discountedPrice: { type: 'number', nullable: true, example: 95 },
        originalPrice: { type: 'number', nullable: true, example: 110 },
      },
    },
    productWeight: { type: 'string', nullable: true, example: '200 g' },
    productImage: { type: 'string', nullable: true },
    productLink: { type: 'string', nullable: true },
    brand: { type: 'string', nullable: true, example: 'Amul' },
    inStock: { type: 'boolean' },
    origin: {
      type: 'string',
      enum: ['bigbasket', 'blinkit', 'dmart', 'starquik'],
      description: 'Which store the product came from',
    },
  },
};

const StoreResult = {
  type: 'object',
  description: 'One store\'s slice of a fan-out. `ok` is false when that store failed.',
  properties: {
    store: { type: 'string', example: 'bigbasket' },
    ok: { type: 'boolean' },
    count: { type: 'integer', example: 30 },
    products: { type: 'array', items: { $ref: '#/components/schemas/StoreProduct' } },
    error: { type: 'string', nullable: true, example: 'Blinkit returned HTTP 403 (Cloudflare block page?)' },
  },
};

const Message = {
  type: 'object',
  properties: { message: { type: 'string' } },
};

// shorthands, since almost every handler answers with one of these
const json = (schema) => ({ content: { 'application/json': { schema } } });
const text = (example) => ({ content: { 'text/plain': { schema: { type: 'string' }, example } } });
const list = (schema) => json({ type: 'array', items: schema });
const msg = (description) => ({ description, ...json(Message) });

const notFound = { description: 'Not found', ...json(Message) };
const serverError = { description: 'Server error', ...json(Message) };

// common parameters
const skip = { name: 'skip', in: 'query', schema: { type: 'integer', default: 0 } };
const limit = { name: 'limit', in: 'query', schema: { type: 'integer', default: 10 } };
const pathId = (name, description) => ({
  name,
  in: 'path',
  required: true,
  schema: { type: 'string' },
  description,
});

// store lookup parameters - only Blinkit reads lat/lon, only DMart reads storeId
const storeLimit = {
  name: 'limit',
  in: 'query',
  schema: { type: 'integer', default: 30, maximum: 100 },
  description: 'Products per store. Starquik caps itself at 10.',
};
const lat = { name: 'lat', in: 'query', schema: { type: 'string' }, example: '19.115171', description: 'Blinkit delivery latitude' };
const lon = { name: 'lon', in: 'query', schema: { type: 'string' }, example: '72.901933', description: 'Blinkit delivery longitude' };
const dmartStoreId = {
  name: 'storeId',
  in: 'query',
  schema: { type: 'string', default: '10151' },
  description: 'DMart catalogue/pricing region',
};

const body = (schema, required = true) => ({
  required,
  content: { 'application/json': { schema } },
});

module.exports = {
  openapi: '3.0.3',
  info: {
    title: 'Recipe & Diet Plan API',
    version: '1.0.0',
    description:
      'Backend for recipes, diet plans, saved recipes and ingredient lookups.\n\n' +
      '**Note:** `verifyJWT` is currently commented out in `server.js`, so none of ' +
      'these endpoints actually check the token yet. `/login` does hand one out.',
  },
  servers: [{ url: 'http://localhost:3500', description: 'Local' }],
  tags: [
    { name: 'Auth', description: 'Register, login, logout' },
    { name: 'Recipes', description: 'Recipe CRUD and search' },
    { name: 'Ingredients', description: 'Ingredient lookup' },
    { name: 'Diet Plans', description: 'Recipes inside a diet plan' },
    { name: 'User', description: 'User profile, saved recipes, history, diet plans' },
    { name: 'Feedback', description: 'User feedback' },
    { name: 'Stores', description: 'Live grocery price lookups across BigBasket, Blinkit, DMart and Starquik' },
  ],
  components: {
    schemas: { Recipe, DietPlan, User, Ingredient, Feedback, Message, StoreProduct, StoreResult },
    securitySchemes: {
      bearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Token from POST /login. Not enforced yet - see the note above.',
      },
    },
  },

  paths: {
    // ---------------------------------------------------------------- Auth
    '/register': {
      post: {
        tags: ['Auth'],
        summary: 'Create a new account',
        requestBody: body({
          type: 'object',
          required: ['username', 'password'],
          properties: {
            username: { type: 'string' },
            password: { type: 'string', format: 'password' },
            firstName: { type: 'string' },
            lastName: { type: 'string' },
            email: { type: 'string' },
            mobileNumber: { type: 'string' },
            vegetarian: { type: 'boolean' },
          },
        }),
        responses: {
          201: { description: 'Created', ...text('New user ahaan created!') },
          400: { description: 'Missing username or password', ...text('Missing username or password') },
          409: { description: 'Username taken', ...text('Username already exists') },
          500: { description: 'Server error', ...text('error: ...') },
        },
      },
    },

    '/login': {
      post: {
        tags: ['Auth'],
        summary: 'Log in and get a JWT',
        requestBody: body({
          type: 'object',
          required: ['username', 'password'],
          properties: {
            username: { type: 'string' },
            password: { type: 'string', format: 'password' },
          },
        }),
        responses: {
          200: {
            description: 'Token valid for 30 days',
            ...json({ type: 'object', properties: { accessToken: { type: 'string' } } }),
          },
          400: { description: 'Missing username or password', ...text('Missing username or password') },
          401: { description: 'Wrong credentials', ...text('Username or password is incorrect') },
          500: { description: 'Server error', ...text('error: ...') },
        },
      },
    },

    '/login/changePassword': {
      post: {
        tags: ['Auth'],
        summary: 'Change a password',
        description: 'Takes the user id in the body - it does not check the old password.',
        requestBody: body({
          type: 'object',
          required: ['id', 'newPassword'],
          properties: {
            id: { type: 'string', description: 'User id' },
            newPassword: { type: 'string', format: 'password' },
          },
        }),
        responses: {
          200: { description: 'Changed', ...text('Password changed successfully') },
          400: { description: 'Missing id or newPassword', ...text('Missing id or newPassword') },
          500: { description: 'Server error', ...text('error: ...') },
        },
      },
    },

    '/logout': {
      get: {
        tags: ['Auth'],
        summary: 'Clear the JWT cookie',
        description: 'Delete the access token on the client too.',
        responses: { 204: { description: 'No content, whether or not a cookie was set' } },
      },
    },

    // ------------------------------------------------------------- Recipes
    '/api/recipes': {
      get: {
        tags: ['Recipes'],
        summary: 'List recipes',
        parameters: [
          skip,
          limit,
          { name: 'cuisine', in: 'query', schema: { type: 'string' }, example: 'Indian' },
        ],
        responses: {
          200: { description: 'Recipes', ...list(Recipe) },
          204: { description: 'No recipes matched' },
          500: { description: 'Failed to fetch recipes' },
        },
      },
      post: {
        tags: ['Recipes'],
        summary: 'Create a recipe',
        requestBody: body(Recipe),
        responses: {
          201: { description: 'Created', ...json(Recipe) },
          400: { description: 'Failed to create recipe' },
        },
      },
    },

    '/api/recipes/search': {
      get: {
        tags: ['Recipes'],
        summary: 'Full text search',
        description: 'Fuzzy search across all recipe fields (Atlas Search).',
        parameters: [
          { name: 'q', in: 'query', required: true, schema: { type: 'string' }, example: 'paneer' },
          skip,
          limit,
        ],
        responses: {
          200: { description: 'Matches', ...list(Recipe) },
          204: { description: 'No results found' },
          400: { description: 'Search key is required', ...json(Message) },
          500: serverError,
        },
      },
    },

    '/api/recipes/autocomplete': {
      get: {
        tags: ['Recipes'],
        summary: 'Autocomplete recipe names',
        description: 'Fuzzy matching kicks in once the query is 6+ characters.',
        parameters: [
          { name: 'q', in: 'query', required: true, schema: { type: 'string' }, example: 'pan' },
          { name: 'limit', in: 'query', schema: { type: 'integer', default: 5 } },
        ],
        responses: {
          200: {
            description: 'Suggestions - only name, veg and image are returned',
            ...list({
              type: 'object',
              properties: {
                _id: { type: 'string' },
                TranslatedRecipeName: { type: 'string' },
                veg: { type: 'boolean', nullable: true },
                'image-url': { type: 'string' },
              },
            }),
          },
          204: { description: 'No suggestions found' },
          400: { description: 'Query parameter "q" is required', ...json(Message) },
          500: serverError,
        },
      },
    },

    '/api/recipes/{id}': {
      parameters: [pathId('id', 'Recipe id')],
      get: {
        tags: ['Recipes'],
        summary: 'Get one recipe',
        responses: {
          200: { description: 'Recipe, or null if the id does not exist', ...json(Recipe) },
          400: { description: 'Failed to find recipe' },
        },
      },
      put: {
        tags: ['Recipes'],
        summary: 'Update a recipe',
        requestBody: body(Recipe),
        responses: {
          200: { description: 'Updated recipe', ...json(Recipe) },
          400: { description: 'Failed to update recipe' },
        },
      },
      delete: {
        tags: ['Recipes'],
        summary: 'Delete a recipe',
        responses: {
          200: { description: 'The deleted recipe', ...json(Recipe) },
          400: { description: 'Failed to delete recipe' },
        },
      },
    },

    // --------------------------------------------------------- Ingredients
    '/api/ingredients': {
      get: {
        tags: ['Ingredients'],
        summary: 'List ingredients in a category',
        description: '`q` is matched against the ingredient **category**, not its name.',
        parameters: [
          { name: 'q', in: 'query', schema: { type: 'string' }, example: 'Dairy' },
          skip,
          { name: 'limit', in: 'query', schema: { type: 'integer', default: 50 } },
        ],
        responses: {
          200: { description: 'Ingredients', ...list(Ingredient) },
          500: serverError,
        },
      },
    },

    // ---------------------------------------------------------- Diet plans
    '/api/dietplans/{dietPlanId}/recipes': {
      parameters: [pathId('dietPlanId', 'Diet plan id')],
      get: {
        tags: ['Diet Plans'],
        summary: 'List the recipes in a diet plan',
        responses: {
          200: { description: 'Recipes', ...list(Recipe) },
          404: notFound,
          500: serverError,
        },
      },
    },

    '/api/dietplans/{dietPlanId}/recipes/{recipeId}': {
      parameters: [pathId('dietPlanId', 'Diet plan id'), pathId('recipeId', 'Recipe id')],
      post: {
        tags: ['Diet Plans'],
        summary: 'Add a recipe to a diet plan',
        description: "Adds the recipe's calories to the plan total.",
        responses: {
          200: msg('Recipe added to diet plan successfully'),
          404: notFound,
          500: serverError,
        },
      },
      delete: {
        tags: ['Diet Plans'],
        summary: 'Remove a recipe from a diet plan',
        responses: {
          200: msg('Recipe removed from diet plan successfully'),
          404: notFound,
          500: serverError,
        },
      },
    },

    // ---------------------------------------------------------------- User
    '/api/user/id/{userId}': {
      get: {
        tags: ['User'],
        summary: 'Get a user by id',
        parameters: [pathId('userId', 'User id')],
        responses: {
          200: { description: 'User', ...json(User) },
          404: notFound,
          500: serverError,
        },
      },
    },

    '/api/user/{username}': {
      get: {
        tags: ['User'],
        summary: 'Get a user by username',
        parameters: [pathId('username', 'Username')],
        responses: {
          200: { description: 'User', ...json(User) },
          404: notFound,
          500: serverError,
        },
      },
    },

    '/api/user/recipes/saved': {
      post: {
        tags: ['User'],
        summary: 'Save a recipe',
        requestBody: body({
          type: 'object',
          required: ['userId', 'recipeId'],
          properties: { userId: { type: 'string' }, recipeId: { type: 'string' } },
        }),
        responses: {
          200: msg('Recipe saved successfully'),
          404: notFound,
          500: serverError,
        },
      },
      delete: {
        tags: ['User'],
        summary: 'Unsave a recipe',
        description: 'Ids go in the body, not the query string.',
        requestBody: body({
          type: 'object',
          required: ['userId', 'recipeId'],
          properties: { userId: { type: 'string' }, recipeId: { type: 'string' } },
        }),
        responses: {
          200: msg('Recipe removed from saved recipes successfully'),
          404: notFound,
          500: serverError,
        },
      },
    },

    '/api/user/recipes/saved/{userId}': {
      get: {
        tags: ['User'],
        summary: "List a user's saved recipes",
        parameters: [pathId('userId', 'User id'), skip, limit],
        responses: {
          200: { description: 'Saved recipes', ...list(Recipe) },
          404: notFound,
          500: serverError,
        },
      },
    },

    '/api/user/recipes/isSaved': {
      get: {
        tags: ['User'],
        summary: 'Check whether a recipe is saved',
        parameters: [
          { name: 'userId', in: 'query', required: true, schema: { type: 'string' } },
          { name: 'recipeId', in: 'query', required: true, schema: { type: 'string' } },
        ],
        responses: {
          200: { description: 'Result', ...json({ type: 'object', properties: { isSaved: { type: 'boolean' } } }) },
          404: notFound,
          500: serverError,
        },
      },
    },

    '/api/user/recipes/history': {
      post: {
        tags: ['User'],
        summary: 'Add a recipe to history',
        requestBody: body({
          type: 'object',
          required: ['userId', 'recipeId'],
          properties: { userId: { type: 'string' }, recipeId: { type: 'string' } },
        }),
        responses: {
          200: msg('Recipe adde successfully'),
          404: notFound,
          500: serverError,
        },
      },
    },

    '/api/user/recipes/history/{userId}': {
      get: {
        tags: ['User'],
        summary: "List a user's recipe history",
        parameters: [pathId('userId', 'User id'), skip, limit],
        responses: {
          200: { description: 'History', ...list(Recipe) },
          404: notFound,
          500: serverError,
        },
      },
    },

    '/api/user/dietplans/{userId}': {
      parameters: [pathId('userId', 'User id')],
      post: {
        tags: ['User'],
        summary: 'Create a diet plan',
        requestBody: body({
          type: 'object',
          required: ['name'],
          properties: { name: { type: 'string' }, description: { type: 'string' } },
        }),
        responses: {
          201: { description: 'Created', ...json(DietPlan) },
          400: msg('Name is required'),
          404: notFound,
          500: serverError,
        },
      },
      get: {
        tags: ['User'],
        summary: "List a user's diet plans",
        responses: {
          200: { description: 'Diet plans', ...list(DietPlan) },
          404: notFound,
          500: serverError,
        },
      },
    },

    '/api/user/dietplans/{dietPlanId}': {
      put: {
        tags: ['User'],
        summary: 'Edit a diet plan',
        parameters: [pathId('dietPlanId', 'Diet plan id')],
        requestBody: body(DietPlan),
        responses: {
          200: { description: 'Updated plan', ...json(DietPlan) },
          404: notFound,
          500: serverError,
        },
      },
    },

    '/api/user/dietplans/{userId}/{dietPlanId}': {
      delete: {
        tags: ['User'],
        summary: 'Delete a diet plan',
        parameters: [pathId('userId', 'User id'), pathId('dietPlanId', 'Diet plan id')],
        responses: {
          200: msg('Diet Plan deleted successfully'),
          404: notFound,
          500: serverError,
        },
      },
    },

    // ------------------------------------------------------------ Feedback
    '/api/feedback': {
      post: {
        tags: ['Feedback'],
        summary: 'Submit feedback',
        requestBody: body({
          type: 'object',
          required: ['title', 'description'],
          properties: {
            title: { type: 'string', maxLength: 100 },
            description: { type: 'string', maxLength: 1000 },
            user_id: { type: 'string', description: 'User id' },
          },
        }),
        responses: {
          201: { description: 'Saved', ...json(Feedback) },
          400: { description: 'Validation error' },
        },
      },
    },
    // ------------------------------------------------------------- Stores
    '/api/ingredients/stores': {
      get: {
        tags: ['Stores'],
        summary: 'List the stores that can be searched',
        responses: {
          200: {
            description: 'Store keys usable as `stores=` or `/api/stores/{store}`',
            ...json({ type: 'object', properties: { stores: { type: 'array', items: { type: 'string' } } } }),
          },
        },
      },
    },

    '/api/ingredients/stores/search': {
      get: {
        tags: ['Stores'],
        summary: 'Search every store at once',
        description:
          'Queries the stores in parallel and returns one entry per store. A store that ' +
          'fails comes back with `ok: false` and an `error` instead of sinking the request, ' +
          'so partial results are normal. Each store gets 15s before it is timed out.',
        parameters: [
          { name: 'q', in: 'query', required: true, schema: { type: 'string' }, example: 'paneer' },
          {
            name: 'stores',
            in: 'query',
            schema: { type: 'string' },
            example: 'bigbasket,dmart',
            description: 'Comma separated subset. Defaults to all of them.',
          },
          storeLimit,
          lat,
          lon,
          dmartStoreId,
        ],
        responses: {
          200: {
            description: 'Results per store',
            ...json({
              type: 'object',
              properties: {
                query: { type: 'string' },
                limit: { type: 'integer' },
                count: { type: 'integer', description: 'Total products across all stores' },
                results: { type: 'array', items: StoreResult },
              },
            }),
          },
          400: { description: 'Missing `q`, or an unknown store name', ...json(Message) },
          502: { description: 'Every store failed', ...json(Message) },
          500: serverError,
        },
      },
    },

    '/api/ingredients/stores/cheapest': {
      get: {
        tags: ['Stores'],
        summary: 'Cheapest match across all stores',
        description:
          'Same fan-out as `/search`, then keeps only in-stock products whose name actually ' +
          'contains the query - store search happily returns loosely related items that ' +
          'would otherwise win on price alone - and sorts by discounted price.',
        parameters: [
          { name: 'q', in: 'query', required: true, schema: { type: 'string' }, example: 'paneer' },
          storeLimit,
          lat,
          lon,
          dmartStoreId,
        ],
        responses: {
          200: {
            description: 'The cheapest product, plus the runners-up it beat',
            ...json({
              type: 'object',
              properties: {
                query: { type: 'string' },
                cheapest: StoreProduct,
                alternatives: { type: 'array', items: StoreProduct },
              },
            }),
          },
          400: { description: 'Query parameter "q" is required', ...json(Message) },
          404: { description: 'No matching in-stock product found', ...json(Message) },
          500: serverError,
        },
      },
    },

    '/api/ingredients/stores/{store}': {
      get: {
        tags: ['Stores'],
        summary: 'Search a single store',
        parameters: [
          {
            name: 'store',
            in: 'path',
            required: true,
            schema: { type: 'string', enum: ['bigbasket', 'blinkit', 'dmart', 'starquik'] },
          },
          { name: 'q', in: 'query', required: true, schema: { type: 'string' }, example: 'paneer' },
          storeLimit,
          lat,
          lon,
          dmartStoreId,
        ],
        responses: {
          200: {
            description: 'Products',
            ...json({
              type: 'object',
              properties: {
                query: { type: 'string' },
                store: { type: 'string' },
                count: { type: 'integer' },
                products: { type: 'array', items: StoreProduct },
              },
            }),
          },
          400: { description: 'Query parameter "q" is required', ...json(Message) },
          404: { description: 'Unknown store', ...json(Message) },
          502: { description: 'The store itself failed or timed out', ...json(Message) },
        },
      },
    },
  },
};
