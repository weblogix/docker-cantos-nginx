###############################################
# Dockerfile to build nginx
# based on CentOS 7 image
###############################################

# Set the base image to CentOS 7
FROM centos:centos7

# Image author/maintainer
MAINTAINER Randy Lowe <randy@weblogix.ca>

# Add repo's

ADD conf/nginx/nginx.repo /etc/yum.repos.d/nginx.repo

# normal updates
RUN yum -y update

# install tools
RUN yum -y install epel-release initscripts nano bind-utils net-tools

# install nginx web server
RUN yum -y install nginx

# nginx configuration
COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# nginx default host
RUN mkdir -p /var/www/html/default
COPY conf/nginx/www/index.html /var/www/html/default

#nginx create folder for additional virtual hosts
RUN mkdir -p /var/www/html/vhosts

# Copy supervisor configuration file
RUN yum -y install supervisor
COPY conf/supervisor/supervisord.conf /etc/supervisord.conf

# Clean up
RUN yum clean all

# Expose ports
EXPOSE 80

CMD ["/usr/bin/supervisord"]
