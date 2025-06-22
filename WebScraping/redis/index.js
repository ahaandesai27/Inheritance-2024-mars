const redis = require('redis');
require('dotenv').config()

const host = process.env.REDIS_HOST;
const port = process.env.REDIS_PORT;
const username = process.env.REDIS_USERNAME;
const password = process.env.REDIS_PASSWORD;

const redisClient = redis.createClient({
  username,
  password,
  socket: {
    host,
    port
  }
});

redisClient.on('error', err => console.error('❌ Redis Client Error:', err));

const connectRedis = async () => {
  if (!redisClient.isOpen) {
    try {
      await redisClient.connect();
      console.log(`Connected to Redis at ${host}:${port}`);
      
      if (host.includes('redis.cloud') || host.includes('redislabs.com')) {
        console.log('Connected to Redis Cloud');
      } else if (host === '127.0.0.1' || host === 'localhost') {
        console.log('Connected to Local Redis');
      } else {
        console.log(' Connected to Custom Redis Host');
      }
    } catch (err) {
      console.error('Failed to connect to Redis:', err);
    }
  }
};

module.exports = { redisClient, connectRedis };
