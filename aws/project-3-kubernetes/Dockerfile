# Dockerfile - Optimized for Minikube builds without internet

FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Copy pre-installed dependencies
COPY node_modules ./node_modules

# Copy application code
COPY . .

# Expose port
EXPOSE 3001

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3001/health || exit 1

# Start the application
CMD ["npm", "start"]
