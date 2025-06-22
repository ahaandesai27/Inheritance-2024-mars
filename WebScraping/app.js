const express = require('express');
const app = express();
const scrapingRouter = require('./api/route'); 
require('dotenv').config()
const cors = require('cors');

app.use(cors({
  origin: '*'
}));

app.use(express.json());

app.use('/api', scrapingRouter);

// Basic health check endpoint
app.get('/', (req, res) => {
  res.send('Ingredient Scraper API is running');
});

// Global error handler (optional)
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
