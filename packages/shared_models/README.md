# shared_models

Pure Dart package containing data models shared across the Snake Universe monorepo.

## Models

### `Score`

Represents a leaderboard entry.

```dart
import 'package:shared_models/shared_models.dart';

final score = Score(name: 'MLJ', score: 42);

// Serialisation
final json = score.toJson();         // {'name': 'MLJ', 'score': 42}
final score2 = Score.fromJson(json); // round-trips correctly
```

**Fields:**

| Field | Type | Description |
|---|---|---|
| `name` | `String` | Player-supplied display name |
| `score` | `int` | Final score at game over |

## Usage

This package is consumed as a Dart workspace dependency — no pub.dev publishing required.

```yaml
# in your pubspec.yaml
dependencies:
  shared_models: any
```

## Development

```sh
dart pub get   # install dependencies
dart test      # run tests
dart analyze   # lint
```
