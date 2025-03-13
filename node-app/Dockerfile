FROM node:22-slim

# Create and change to the app directory
WORKDIR /usr/src/app

# Copy application dependency manifests
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy local code to the container image
COPY . .

# Configure and expose port
ENV PORT=8080
EXPOSE 8080

# Run the web service on container startup
CMD [ "npm", "run", "start" ]
