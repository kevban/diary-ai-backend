# Official Dart image: https://hub.docker.com/_/dart
# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.17)
FROM dart:stable AS build

# Install dart_frog
RUN pub global activate dart_frog

# Set the path for pub global executables
ENV PATH="${PATH}:/root/.pub-cache/bin"

# Set the working directory to /app
WORKDIR /app

# Copy the pubspec.yaml and pubspec.lock files to the container
COPY pubspec.* ./

# Run `dart_frog build` to build the application
RUN dart_frog build

# Expose port 8080
EXPOSE 8080

# Start the application
CMD ["dart", "bin/server.dart"]