# Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies first (better caching)
COPY package.json yarn.lock ./
COPY lerna.json ./

# Install dependencies with legacy peer deps to handle conflicts
RUN yarn install --legacy-peer-deps

# Copy the rest of the application
COPY . .

# Build the application
RUN yarn bootstrap --legacy-peer-deps
RUN cd examples/gatsby-minimal-starter && yarn install --legacy-peer-deps && yarn build

# Production stage
FROM nginx:alpine

# Copy built assets from builder
COPY --from=builder /app/examples/gatsby-minimal-starter/public /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 