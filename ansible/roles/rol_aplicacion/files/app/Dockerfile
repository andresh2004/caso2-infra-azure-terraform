FROM nginx:alpine

# Copia del archivo de configuración de nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copia del contenido del sitio
COPY index.html /usr/share/nginx/html/index.html

# Copia del archivo de autenticación
COPY auth/.htpasswd /etc/nginx/.htpasswd

# Copia de certificados SSL
COPY ssl/cert.pem /etc/ssl/certs/cert.pem
COPY ssl/key.pem /etc/ssl/private/key.pem

CMD ["nginx", "-g", "daemon off;"]
