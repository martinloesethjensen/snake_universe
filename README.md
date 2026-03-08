# Snake Universe

A retro 8-bit Snake game built with Flutter and Flame, featuring a global leaderboard powered by Supabase and hosted on Firebase.

## Stack

| Layer | Technology |
|---|---|
| Game engine | [Flame](https://flame-engine.org/) 1.35+ on Flutter |
| Leaderboard | [Supabase](https://supabase.com/) (`high_scores` table) |
| Hosting | [Firebase Hosting](https://firebase.google.com/docs/hosting) |
| Font | PressStart2P (bundled, no network fetch) |

## Monorepo Structure

```
snake_universe/
├── snake_game/          # Flutter + Flame application
├── packages/
│   └── shared_models/   # Pure Dart models shared across packages
├── firebase.json        # Firebase Hosting config (serves snake_game/build/web)
└── pubspec.yaml         # Dart workspace root
```

> The game communicates directly with Supabase from the client — no separate backend service is needed.

## Packages

### `snake_game`

The playable game. See [`snake_game/README.md`](snake_game/README.md) for full details.

### `packages/shared_models`

Pure Dart package with the `Score` model used by the game to read/write leaderboard entries. See [`packages/shared_models/README.md`](packages/shared_models/README.md).

## Environment Setup

Supabase credentials are injected at build time via Dart environment variables — they are never checked into source control.

```sh
# Run locally
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
            --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key

# Build for web
flutter build web --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
                  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

## Deployment

```sh
cd snake_game
flutter build web --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...
cd ..
firebase deploy --only hosting
```

The Firebase project is `snake-game-90a9e`. Built web assets are served from `snake_game/build/web` with all routes rewritten to `index.html`.

## Supabase Schema

```sql
create table high_scores (
  id    bigserial primary key,
  name  text      not null,
  score int       not null
);
```

The game fetches the top 25 scores ordered by `score desc` and inserts a new row on submission.
