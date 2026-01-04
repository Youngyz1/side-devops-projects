FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

# Install curl for ECS health check
RUN apk add --no-cache curl

COPY . .

EXPOSE 3001

CMD ["node", "app.js"]
