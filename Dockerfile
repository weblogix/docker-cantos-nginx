###############################################
# Dockerfile to build nginx
# based on CentOS 7 image
###############################################

# Set the base image to CentOS 7
FROM centos:centos7

# Image author/maintainer
MAINTAINER Randy Lowe <randy@weblogix.ca>

CMD ["/usr/sbin/init"]
RUN yum install -y ca-certificates

# Add repo's
ADD conf/nginx/nginx.repo /etc/yum.repos.d/nginx.repo

# normal updates
RUN yum -y update

# install tools
RUN yum -y install epel-release initscripts nano bind-utils net-tools which

# install nginx web server
RUN yum -y install nginx

# nginx configuration
COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# nginx default host
RUN mkdir -p /var/www/html/default
COPY conf/nginx/www/ /var/www/html/default

#nginx create folder for additional virtual hosts
RUN mkdir -p /var/www/html/vhosts
RUN mkdir -p /etc/nginx/conf.d/sites-enabled

# Generate self-signed SSL
RUN mkdir -p /etc/ssl/private
RUN mkdir -p /etc/ssl/certs
RUN openssl genrsa -des3 -passout pass:x -out server.pass.key 2048
RUN openssl rsa -passin pass:x -in server.pass.key -out /etc/ssl/private/nginx-selfsigned.key
RUN rm server.pass.key
RUN openssl req -new -key /etc/ssl/private/nginx-selfsigned.key  -out server.csr \
  -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=example.com"
RUN openssl x509 -req -days 365 -in server.csr -signkey /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
RUN openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Copy supervisor configuration file
RUN yum -y install supervisor
COPY conf/supervisor/supervisord.conf /etc/supervisord.conf

# Forward logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# Clean up
RUN yum clean all

# Expose ports
EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/init"]
CMD ["/usr/bin/supervisord"]