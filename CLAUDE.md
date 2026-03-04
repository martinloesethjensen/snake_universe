# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Monorepo with two Dart packages and packages folder with shared packages:
- `snake_game/` — Flutter + Flame 2D snake game (retro 8-bit style)
- `snake_backend/` — Dart Frog web backend, hosted on Globe (globe.dev)
- `packages/` — shared packages

## Commands

### snake_game (Flutter/Flame)

```sh
cd snake_game
flutter pub get          # install dependencies
flutter run              # run on connected device/emulator
flutter run -d chrome    # run on web
flutter run -d macos     # run on macOS
flutter test             # run all tests
flutter test test/widget_test.dart  # run a single test file
flutter analyze          # lint
```

### snake_backend (Dart Frog)

```sh
cd snake_backend
dart pub get             # install dependencies
dart_frog dev            # start dev server (hot reload)
dart test                # run all tests
dart test test/routes/index_test.dart  # run a single test file
dart analyze             # lint
```

## Architecture

### snake_game

The game logic lives entirely in `lib/snake_game.dart` (`SnakeGame` extends `FlameGame`). Key design decisions:

- **Fixed virtual resolution** (480×520) via `CameraComponent.withFixedResolution` — scales correctly on all screen sizes.
- **Grid coordinates** use `Point<int>` from `dart:math` (not `Vector2`) for correct value equality in collision detection.
- **Component separation**: `GameBoard` (static background/grid), `SnakeComponent` (snake body), `FoodComponent` (food) all live in the `World`. The score HUD (`TextComponent`) lives in the camera viewport.
- **Game state** (snake body list, direction, score, timers) is owned by `SnakeGame`; visual components are synced every frame via `update()`.
- **Input**: Arrow keys/WASD for desktop, swipe gestures for mobile/web — both handled in `SnakeGame`.
- Grid constants (`kCols`, `kRows`, `kCell`, etc.) are centralized in `lib/constants.dart`.

### snake_backend

Minimal Dart Frog app. Routes are file-based under `routes/`. Currently only has a root `index.dart` route.
