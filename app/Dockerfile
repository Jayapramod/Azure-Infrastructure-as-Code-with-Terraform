FROM nginx:stable-alpine

# Copy custom nginx config and site content
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
COPY certs /etc/nginx/certs

EXPOSE 80 443
