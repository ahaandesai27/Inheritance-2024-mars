const { format } = require('date-fns');
const { v4: uuid } = require('uuid');

const fs = require('fs');
const fsPromises = require('fs').promises;
const path = require('path');

const logEvents = async (message, logFileName) => {
    const dateTime = `${format(new Date(), 'yyyyMMdd\tHH:mm:ss')}`;
    const logMessage = `${dateTime}\t${uuid()}\t${message}\n`;

    try {
        // if logs folder not existing, create it
        if (!fs.existsSync(path.join(__dirname, '..', 'logs'))) {
            await fsPromises.mkdir(path.join(__dirname, '..', 'logs'));
        }
        // append logMessage to logFileName
        await fsPromises.appendFile(path.join(__dirname, '..', 'logs', logFileName), logMessage);
    } catch (err) {
        console.log(err);
    }
}
const logger = async (req, res, next) => {
    const message = `${req.method}\t${req.headers.origin}\t${req.url}\t${req.ip}`;
    await logEvents(message, 'reqLog.txt');
    console.log(message);
    next();
}
module.exports = {logger,logEvents};
