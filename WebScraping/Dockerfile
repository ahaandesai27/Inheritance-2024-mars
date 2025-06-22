FROM node:22-slim

WORKDIR /app

COPY install-chrome.sh ./
RUN chmod +x install-chrome.sh && ./install-chrome.sh

COPY package*.json ./
RUN npm install --omit=dev
RUN apt install vim             

COPY . .

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

EXPOSE 3000
CMD ["node", "app.js"]
