const { createClient } = require('redis');
require('dotenv').config();

const redisClient = createClient({
    url: process.env.REDIS_URL || 'redis://127.0.0.1:6379',
});

redisClient.on('error', (err) => console.error('Redis error:', err.message));

const connectRedis = async () => {
    try {
        await redisClient.connect();
        console.log('Redis connected');
    } catch (err) {
        // caching is optional - the app still serves everything from upstream
        console.error('Redis connection failed:', err.message);
    }
};

// Store prices are quoted per day, so every entry dies at the next 00:00 IST.
// Derived from the epoch rather than a local Date so it holds on a UTC server.
const secondsUntilMidnightIST = () => {
    const DAY_MS = 24 * 60 * 60 * 1000;
    const IST_OFFSET_MS = 5.5 * 60 * 60 * 1000;

    const sinceMidnightIST = (Date.now() + IST_OFFSET_MS) % DAY_MS;
    return Math.ceil((DAY_MS - sinceMidnightIST) / 1000);
};

const cacheGet = async (key) => {
    if (!redisClient.isReady) return null;

    try {
        const cached = await redisClient.get(key);
        return cached ? JSON.parse(cached) : null;
    } catch (err) {
        console.error('Redis get failed:', err.message);
        return null;
    }
};

const cacheSet = async (key, value) => {
    if (!redisClient.isReady) return;

    try {
        await redisClient.setEx(key, secondsUntilMidnightIST(), JSON.stringify(value));
    } catch (err) {
        console.error('Redis set failed:', err.message);
    }
};

module.exports = { redisClient, connectRedis, cacheGet, cacheSet };
