#############################################################
# Build Stage
FROM node:current-alpine3.20 AS build
WORKDIR /app/

COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy application files
COPY ./src ./src
COPY ./public ./public

# Build the React app
RUN npm run build

#############################################################
# Runtime Stage (Nginx)
FROM nginx:1.27.3-alpine

# Set working directory to Nginx's default HTML directory
WORKDIR /usr/share/nginx/html

# Remove the default Nginx static files
RUN rm -rf ./*

# Copy the built React app from the build stage
COPY --from=build /app/build/ .

# Copy custom Nginx configuration if needed
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80 for web access
EXPOSE 80

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
