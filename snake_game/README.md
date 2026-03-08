# snake_game

A retro 8-bit Snake game built with [Flutter](https://flutter.dev/) and the [Flame](https://flame-engine.org/) 2D game engine. Responsive layout adapts to any screen size or orientation, with controls for keyboard (desktop) and swipe gestures (mobile/web).

## Features

- Smooth, fixed-timestep snake movement with speed scaling as your score grows
- Responsive grid that fills the screen in both portrait and landscape
- Global leaderboard — submit your score and see the top 25 players (Supabase)
- Keyboard shortcuts and swipe gesture input
- Neon retro aesthetic with PressStart2P font

## Controls

| Action | Keyboard | Touch |
|---|---|---|
| Move | Arrow keys or WASD | Swipe |
| Pause / Resume | P or Escape | Pause button |
| Start / Restart | Enter, Space, or any arrow | Tap prompt |
| Dismiss overlay | Escape | Back button |

## Architecture

```
lib/
├── main.dart                  # App entry point, Supabase init, overlay registration
├── snake_game.dart            # SnakeGame (FlameGame) — all game state and input
├── game_layout.dart           # Responsive layout: grid dimensions, cell size
├── constants.dart             # Shared constants
├── intents.dart               # Flutter Intent definitions (keyboard shortcuts)
├── components/
│   ├── game_board.dart        # Static grid background (World component)
│   ├── snake_component.dart   # Snake body rendering (World component)
│   └── food_component.dart    # Food pellet rendering (World component)
├── overlays/
│   ├── start_overlay.dart     # Start screen
│   ├── game_over_overlay.dart # Game-over screen + score submission
│   ├── leaderboard_overlay.dart # Top 25 leaderboard
│   └── pause_overlay.dart     # Pause menu
└── services/
    └── api_service.dart       # Supabase queries (fetch scores, submit score)
```

**Key design decisions:**

- **Dynamic responsive layout** — `GameLayout.forCanvas()` computes the grid dimensions and cell size from the actual canvas size at runtime. Portrait and landscape orientations use different column/row counts.
- **Grid coordinates** use `Point<int>` from `dart:math` (not `Vector2`) so equality checks in collision detection work correctly without custom comparators.
- **Component/state separation** — game state (snake body, direction, score, timers) lives in `SnakeGame`; visual components are synced every frame in `update()`.
- **Two-slot input buffer** — direction presses are buffered so rapid key presses faster than one game step are not silently dropped.
- **Camera** is set up with `Anchor.topLeft` and a 1:1 pixel scale against the world so pixel-perfect grid rendering is straightforward.

## Running

```sh
flutter pub get

flutter run                # connected device or emulator
flutter run -d chrome      # web
flutter run -d macos       # macOS desktop
```

Supabase credentials must be provided at run time:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

## Building for web

```sh
flutter build web \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

The output in `build/web/` is deployed via Firebase Hosting from the repo root (`firebase deploy --only hosting`).

## Testing & linting

```sh
flutter test        # run all tests
flutter analyze     # lint
```
