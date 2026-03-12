# Build stage
FROM dart:stable AS build

# Mirror the repo workspace structure
COPY pubspec.yaml /workspace/pubspec.yaml
COPY pubspec.lock /workspace/pubspec.lock
COPY packages/ /workspace/packages/
COPY snake_game/pubspec.yaml /workspace/snake_game/pubspec.yaml
COPY backend/ /workspace/backend/

WORKDIR /workspace/backend

RUN dart pub get
RUN dart run dart_frog_cli:dart_frog build

# Runtime stage
FROM debian:bookworm-slim

WORKDIR /app

COPY --from=build /workspace/backend/build/bin/server.dart.exe ./server

EXPOSE 8080

CMD ["./server"]
