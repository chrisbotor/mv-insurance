# Use a lightweight Nginx web server image
FROM nginx:alpine

# Copy the compiled Flutter web files into Nginx
COPY build/web /usr/share/nginx/html

# Expose port 80 so Cloudflare can route traffic to it
EXPOSE 80

# Start the web server
CMD ["nginx", "-g", "daemon off;"]