# Use the official Node.js Alpine image
FROM node:14-alpine

#Install curl for health checks
RUN apk add curl

# Set the working directory
WORKDIR /usr/src/app

# Install dependencies (Node.js dependencies)
COPY package*.json ./
RUN npm install
RUN npm install -g serve
# Copy the rest of the application code
COPY . .
# Expose the port the app runs on
EXPOSE 3000

# Build the React app for production
RUN npm run build

# Start the application
CMD ["serve","-s","build"]
