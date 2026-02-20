# Use the pre-built container as base image
FROM hshar/webapp

# Maintainer information
LABEL maintainer="devops@abode.com"
LABEL description="Abode Software Web Application"

# Set working directory
WORKDIR /var/www/html

# Copy application files to the container
COPY . /var/www/html/

# Set proper permissions
RUN chmod -R 755 /var/www/html

# Expose port 80 for web traffic
EXPOSE 8081

# Health check to ensure the application is running
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8081/ || exit 1

# Start Apache in foreground mode
CMD ["apachectl", "-D", "FOREGROUND"]
