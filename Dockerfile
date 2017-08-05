###############################################
# Dockerfile to build a custom nginx container.
###############################################

# Set the base image to latest nginx image
FROM nginx:latest

# Image author/maintainer
MAINTAINER Randy Lowe <randy@weblogix.ca>

RUN apt-get update
RUN apt-get install -y openssl bash letsencrypt

# nginx configuration
RUN mkdir -p /etc/nginx/modules
COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx/modules /etc/nginx/modules
COPY conf/nginx/conf.d /etc/nginx/conf.d

# nginx default host
RUN mkdir -p /var/www/html/default
RUN mkdir -p /var/lib/php/session
RUN chown -Rf nginx:nginx /var/lib/php/session
COPY www/ /var/www/html/default

# Expose ports
EXPOSE 80
EXPOSE 443
