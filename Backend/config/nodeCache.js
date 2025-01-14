const nodeCache = require('node-cache')

const cache = new nodeCache({
    'checkperiod': '86400'
})

module.exports = cache;