# Snake Universe

A retro 8-bit Snake game built with Flutter and Flame, featuring a global leaderboard powered by Supabase and hosted on Firebase.

## Stack

| Layer | Technology |
|---|---|
| Game engine | [Flame](https://flame-engine.org/) 1.35+ on Flutter |
| Backend API | [Dart Frog](https://dartfrog.dev/) — hosted on [Railway](https://railway.com) |
| Leaderboard | [Supabase](https://supabase.com/) (`high_scores` table) |
| Hosting | [Firebase Hosting](https://firebase.google.com/docs/hosting) |
| Font | PressStart2P (bundled, no network fetch) |

## Monorepo Structure

```
snake_universe/
├── snake_game/          # Flutter + Flame application
├── backend/             # Dart Frog API server (deployed to Railway)
├── packages/
│   └── shared_models/   # Pure Dart models shared across packages
├── firebase.json        # Firebase Hosting config (serves snake_game/build/web)
└── pubspec.yaml         # Dart workspace root
```

## Packages

### `snake_game`

The playable game. See [`snake_game/README.md`](snake_game/README.md) for full details.

### `backend`

Dart Frog API server with routes under `routes/`. Handles leaderboard reads and writes, deployed to [Railway](https://railway.com). See [`backend/README.md`](backend/README.md) for full details.

### `packages/shared_models`

Pure Dart package with the `Score` model used by the game to read/write leaderboard entries. See [`packages/shared_models/README.md`](packages/shared_models/README.md).

## Environment Setup

Supabase credentials are injected at build time via Dart environment variables — they are never checked into source control.

```sh
# Run locally
flutter run

# Build for web
flutter build web
```

## Deployment

### Game (Firebase Hosting)

Deployed automatically via GitHub Actions on push to `main`.

```sh
cd snake_game
flutter build web --release
cd ..
firebase deploy --only hosting
```

The Firebase project is `snake-game-90a9e`. Built web assets are served from `snake_game/build/web` with all routes rewritten to `index.html`.

### Backend (Railway)

The `backend/` Dart Frog server is deployed to [Railway](https://railway.com) using the `backend/Dockerfile`.

```sh
cd backend
dart_frog dev   # local dev with hot reload
```

## Supabase Schema

```sql
create table high_scores (
  id    bigserial primary key,
  name  text      not null,
  score int       not null
);
```

The game fetches the top 25 scores ordered by `score desc` and inserts a new row on submission.
