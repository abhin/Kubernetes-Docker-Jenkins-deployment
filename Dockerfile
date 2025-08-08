# Use nginx lightweight image
FROM nginx:alpine

# Copy index.html to nginx's default html folder
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start nginx (default command already runs nginx in foreground)
