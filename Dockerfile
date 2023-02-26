# Use an official Dart image as the base image
FROM google/dart:2.14.4

# Set the working directory to /app
WORKDIR /app

# Copy the pubspec.yaml and pubspec.lock files to the container
COPY pubspec.* ./

# Copy the entire project to the container
COPY . .

# Run `dart_frog build` to build the application
RUN dart pub global activate dart_frog && \
    /root/.pub-cache/bin/dart_frog build

# Expose port 8080
EXPOSE 8080

# Start the application
CMD ["dart", "bin/server.dart"]