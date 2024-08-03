# # FROM node:6-stretch
# FROM node:18.13.0

# RUN mkdir /usr/src/goof
# RUN mkdir /tmp/extracted_files
# COPY . /usr/src/goof
# WORKDIR /usr/src/goof

# RUN npm install
# EXPOSE 3001
# EXPOSE 9229
# ENTRYPOINT ["npm", "start"]

# Use an official Node.js image
FROM node:18.13.0

# Create a directory for the application
RUN mkdir /usr/src/goof

# Create a temporary directory
RUN mkdir /tmp/extracted_files

# Set the working directory
WORKDIR /usr/src/goof

# Copy the application code
COPY . /usr/src/goof

# Install dependencies
RUN npm install

# Expose ports
EXPOSE 3001
EXPOSE 9229

# Create a non-root user and switch to it
RUN useradd -m docker
USER docker

# Add a health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3001/ || exit 1

# Define the entry point
ENTRYPOINT ["npm", "start"]
