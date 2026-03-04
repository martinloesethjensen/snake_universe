import 'dart:math' show Point, Random, max;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/food_component.dart';
import 'components/game_board.dart';
import 'components/snake_component.dart';
import 'constants.dart';

enum Direction { up, down, left, right }

/// A fully playable Snake game built with Flame 1.x.
///
/// Architecture:
///   - Fixed virtual resolution (480×520) via [CameraComponent.withFixedResolution]
///     so the game scales correctly on every screen size.
///   - Grid positions use [Point<int>] from dart:math, which provides correct
///     value equality (unlike [Vector2] which compares by reference).
///   - Visual components ([SnakeComponent], [FoodComponent], [GameBoard]) live
///     in the [World]; the score [TextComponent] lives in the viewport (HUD).
///   - Input: Arrow keys / WASD for desktop; swipe gestures for mobile/web.
class SnakeGame extends FlameGame with KeyboardEvents, DragCallbacks, TapCallbacks {
  SnakeGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: kGameW,
            height: kGameH,
          ),
        );

  // ── Game state ─────────────────────────────────────────────────────────────
  Direction _currentDir = Direction.right;
  Direction _nextDir = Direction.right;

  /// Snake body in grid coordinates. Index 0 = head.
  final List<Point<int>> _snake = [];
  Point<int> _food = const Point(5, 5);

  int _score = 0;
  bool _isGameOver = false;
  bool _isPaused = false;

  double _moveTimer = 0;
  double _moveSpeed = 0.18; // seconds between steps; decreases as score grows

  // ── Components ─────────────────────────────────────────────────────────────
  late SnakeComponent _snakeComp;
  late FoodComponent _foodComp;
  late TextComponent _scoreText;
  late TextComponent _gameOverText;

  // ── Drag tracking (swipe input) ─────────────────────────────────────────────
  final Vector2 _dragDelta = Vector2.zero();

  // ── FlameGame overrides ────────────────────────────────────────────────────

  @override
  Color backgroundColor() => const Color(0xFF0A0F0A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Place world origin at top-left so grid coords map naturally.
    camera.viewfinder.anchor = Anchor.topLeft;

    _initState();

    // World components
    await world.add(GameBoard());

    _snakeComp = SnakeComponent();
    await world.add(_snakeComp);

    _foodComp = FoodComponent();
    await world.add(_foodComp);
    _syncFood();

    // Score HUD — lives in viewport space so it overlays the HUD strip.
    _scoreText = TextComponent(
      text: 'SCORE: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF39FF14),
          fontSize: 16,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      position: Vector2(8, kRows * kCell + 10),
    );
    await camera.viewport.add(_scoreText);

    // Game-over overlay — lives in world space, added/removed dynamically.
    _gameOverText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFF3366),
          fontSize: 16,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          height: 1.8,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(kGameW / 2, kRows * kCell / 2),
    );
  }

  @override
  void update(double dt) {
    // Always update children (food pulse animation, etc.)
    super.update(dt);

    if (_isGameOver || _isPaused) return;

    _moveTimer += dt;
    if (_moveTimer >= _moveSpeed) {
      _moveTimer = 0;
      _currentDir = _nextDir;
      _step();
    }

    // Sync visuals every frame.
    _snakeComp.body = List.from(_snake);
    _scoreText.text = 'SCORE: $_score';
  }

  // ── Game logic ─────────────────────────────────────────────────────────────

  void _initState() {
    _snake
      ..clear()
      ..addAll(const [Point(10, 10), Point(9, 10), Point(8, 10)]);
    _currentDir = Direction.right;
    _nextDir = Direction.right;
    _score = 0;
    _moveTimer = 0;
    _moveSpeed = 0.18;
    _isGameOver = false;
    _spawnFood();
  }

  void _spawnFood() {
    final rng = Random();
    Point<int> candidate;
    do {
      candidate = Point(rng.nextInt(kCols), rng.nextInt(kRows));
    } while (_snake.contains(candidate));
    _food = candidate;
  }

  void _syncFood() {
    _foodComp.position = Vector2(_food.x * kCell, _food.y * kCell);
  }

  void _step() {
    final head = _snake.first;
    final next = switch (_currentDir) {
      Direction.up => Point(head.x, head.y - 1),
      Direction.down => Point(head.x, head.y + 1),
      Direction.left => Point(head.x - 1, head.y),
      Direction.right => Point(head.x + 1, head.y),
    };

    // Wall collision
    if (next.x < 0 || next.x >= kCols || next.y < 0 || next.y >= kRows) {
      _triggerGameOver();
      return;
    }

    // Self-collision — exclude the tail because it will vacate its cell
    // (unless we grow, but food can never be on the tail cell due to _spawnFood).
    final bodyWithoutTail = _snake.sublist(0, _snake.length - 1);
    if (bodyWithoutTail.contains(next)) {
      _triggerGameOver();
      return;
    }

    _snake.insert(0, next);

    if (next == _food) {
      _score++;
      // Speed up: cap at one step every 60 ms (~16 steps/s)
      _moveSpeed = max(0.06, 0.18 - _score * 0.005);
      _spawnFood();
      _syncFood();
    } else {
      _snake.removeLast();
    }
  }

  void _triggerGameOver() {
    _isGameOver = true;
    _gameOverText.text = 'GAME  OVER\nSCORE: $_score\nTAP / SPACE TO RETRY';
    world.add(_gameOverText);
  }

  void _restart() {
    _gameOverText.removeFromParent();
    _initState();
    _syncFood();
  }

  // ── Keyboard input (desktop) ───────────────────────────────────────────────

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (_isGameOver) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        _restart();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW) {
      if (_currentDir != Direction.down) _nextDir = Direction.up;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS) {
      if (_currentDir != Direction.up) _nextDir = Direction.down;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      if (_currentDir != Direction.right) _nextDir = Direction.left;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      if (_currentDir != Direction.left) _nextDir = Direction.right;
    } else if (event.logicalKey == LogicalKeyboardKey.keyP ||
        event.logicalKey == LogicalKeyboardKey.escape) {
      _isPaused = !_isPaused;
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  // ── Touch / swipe input (mobile & web) ────────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    if (_isGameOver) _restart();
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragDelta.setZero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _dragDelta.add(event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    // Ignore micro-taps
    if (_dragDelta.length < 20 || _isGameOver) return;

    if (_dragDelta.x.abs() > _dragDelta.y.abs()) {
      // Horizontal swipe
      if (_dragDelta.x > 0 && _currentDir != Direction.left) {
        _nextDir = Direction.right;
      } else if (_dragDelta.x < 0 && _currentDir != Direction.right) {
        _nextDir = Direction.left;
      }
    } else {
      // Vertical swipe
      if (_dragDelta.y > 0 && _currentDir != Direction.up) {
        _nextDir = Direction.down;
      } else if (_dragDelta.y < 0 && _currentDir != Direction.down) {
        _nextDir = Direction.up;
      }
    }
  }
}
