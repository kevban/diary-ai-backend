# Official Dart image: https://hub.docker.com/_/dart
# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.17)
FROM dart:stable AS build

RUN dart pub get

RUN dart_frog build

RUN dart build\bin\server.dart