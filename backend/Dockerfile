# Build stage
FROM dart:stable AS build

WORKDIR /app

# Copy workspace-level pubspec files
COPY pubspec.yaml /pubspec.yaml
COPY pubspec.lock /pubspec.lock

# Copy packages
COPY packages/ /packages/

# Copy backend source
COPY backend/ .

# Install dependencies and build
RUN dart pub get
RUN dart run dart_frog_cli:dart_frog build

# Runtime stage
FROM dart:stable-small

WORKDIR /app

# Copy the compiled output from build stage
COPY --from=build /app/build/bin/server.dart.exe ./server

EXPOSE 8080

CMD ["./server"]
