# Build stage
FROM dart:stable AS build

# Mirror the repo workspace structure
COPY pubspec.yaml /workspace/pubspec.yaml
COPY pubspec.lock /workspace/pubspec.lock
COPY packages/ /workspace/packages/
COPY backend/ /workspace/backend/

# Remove snake_game from workspace — it requires Flutter SDK which isn't available here
RUN sed -i '/snake_game/d' /workspace/pubspec.yaml

WORKDIR /workspace/backend

RUN dart pub get
RUN dart run dart_frog_cli:dart_frog build
WORKDIR /workspace/backend/build
RUN dart pub get
RUN dart compile exe bin/server.dart -o bin/server

# Runtime stage
FROM debian:bookworm-slim

WORKDIR /app

COPY --from=build /workspace/backend/build/bin/server ./server

EXPOSE 8080

CMD ["./server"]
