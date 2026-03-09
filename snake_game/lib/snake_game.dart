import 'dart:math' show Point, Random, max;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'components/food_component.dart';
import 'components/game_board.dart';
import 'components/snake_component.dart';
import 'game_layout.dart';

export 'game_layout.dart';

enum Direction { up, down, left, right }

/// Overlay key constants — used by both [SnakeGame] and main.dart.
const kOverlayStartScreen = 'StartScreen';
const kOverlayGameOver = 'GameOver';
const kOverlayLeaderboard = 'Leaderboard';
const kOverlayPause = 'Pause';

/// A fully playable Snake game built with Flame.
///
/// Layout is computed from the actual canvas size so the grid fills the screen
/// in both portrait (mobile) and landscape (desktop) orientations.
class SnakeGame extends FlameGame with KeyboardEvents, DragCallbacks {
  // ── Layout ─────────────────────────────────────────────────────────────────

  /// Current responsive layout. Updated on [onGameResize].
  late GameLayout layout;

  // ── Game state ─────────────────────────────────────────────────────────────
  Direction _currentDir = Direction.right;
  Direction _nextDir = Direction.right;
  Direction? _queuedDir; // second-slot buffer for rapid key presses

  /// Snake body in grid coordinates. Index 0 = head.
  final List<Point<int>> _snake = [];
  Point<int> _food = const Point(5, 5);

  int _score = 0;
  bool _isGameOver = false;
  bool _isPaused = false;
  bool _rebuilding = false; // true while components are being torn down/rebuilt
  bool _waitingToStart = true; // true on start screen, before the first move

  /// True while the leaderboard is open over a live game (not game-over).
  bool _leaderboardPausedGame = false;

  double _moveTimer = 0;
  double _moveSpeed = 0.18; // seconds between steps; decreases as score grows

  // ── Components ─────────────────────────────────────────────────────────────
  late GameBoard _board;
  late SnakeComponent _snakeComp;
  late FoodComponent _foodComp;
  late TextComponent _scoreText;

  // ── Drag tracking (swipe input) ─────────────────────────────────────────────
  final Vector2 _dragDelta = Vector2.zero();

  // ── Focus management ────────────────────────────────────────────────────────

  /// Set by main.dart to the same FocusNode passed to GameWidget.
  /// Used to explicitly recapture keyboard focus after overlays are dismissed.
  FocusNode? gameFocusNode;

  // ── Public API (used by Flutter overlays) ──────────────────────────────────

  /// Notifies Flutter widgets whether the pause button should be visible.
  final ValueNotifier<bool> pauseButtonVisibleNotifier = ValueNotifier(true);

  /// Notifies Flutter widgets of the current HUD strip height so buttons
  /// can be vertically aligned with the SCORE text.
  final ValueNotifier<double> hudHeightNotifier = ValueNotifier(40.0);

  /// Final score to display in the Game Over overlay.
  int get finalScore => _score;

  /// Called by the start-screen overlay (tap or key press) to begin play.
  void startGame() {
    if (!_waitingToStart) return;
    _waitingToStart = false;
    pauseButtonVisibleNotifier.value = true;
    overlays.remove(kOverlayStartScreen);
  }

  /// Remove game-over overlay and restart.
  void restart() {
    overlays.remove(kOverlayGameOver);
    overlays.remove(kOverlayLeaderboard);
    overlays.remove(kOverlayPause);
    _isPaused = false;
    pauseButtonVisibleNotifier.value = true;
    _leaderboardPausedGame = false;
    _restart();
    _returnFocusToGame();
  }

  /// Toggle pause state (called from pause button or keyboard).
  void togglePause() {
    if (_isGameOver || overlays.isActive(kOverlayLeaderboard)) return;
    _isPaused = !_isPaused;
    pauseButtonVisibleNotifier.value = !_isPaused;
    if (_isPaused) {
      overlays.add(kOverlayPause);
    } else {
      overlays.remove(kOverlayPause);
    }
  }

  /// Show the leaderboard (called after score submission or via trophy button).
  void openLeaderboard() {
    overlays.remove(kOverlayGameOver);
    if (!_isGameOver) {
      _isPaused = true;
      _leaderboardPausedGame = true;
    }
    pauseButtonVisibleNotifier.value = false;
    overlays.add(kOverlayLeaderboard);
  }

  /// Close the leaderboard and resume or restart as appropriate.
  void closeLeaderboard() {
    overlays.remove(kOverlayLeaderboard);
    if (_leaderboardPausedGame) {
      _isPaused = false;
      _leaderboardPausedGame = false;
      pauseButtonVisibleNotifier.value = true;
    } else {
      // Came from game-over flow — restart fresh.
      _restart();
    }
    _returnFocusToGame();
  }

  /// After dismissing an overlay that captured keyboard focus (e.g. the
  /// game-over TextField), explicitly release focus so the GameWidget can
  /// recapture it via its internal autofocus — restoring key event delivery.
  void _returnFocusToGame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gameFocusNode?.requestFocus();
    });
  }

  // ── FlameGame overrides ────────────────────────────────────────────────────

  @override
  Color backgroundColor() => const Color(0xFF0A0F0A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    layout = GameLayout.forCanvas(size.x, size.y);

    // World origin at top-left; camera shows world at 1-to-1 pixel scale.
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    _initState();
    await _buildComponents();
    _showStartScreen();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isLoaded) return;

    final newLayout = GameLayout.forCanvas(size.x, size.y);
    if (layout.sameGrid(newLayout)) {
      // Cell size may have changed slightly — update layout so components
      // pick up the new dimensions on their next render without a full reset.
      layout = newLayout;
      _updateComponentLayouts();
      return;
    }

    // Grid dimensions changed (e.g. orientation flip or mobile keyboard opening)
    // — full reinitialisation. Capture state before teardown so we can restore
    // it rather than always landing on the start screen.
    // Defer to a post-frame callback: onGameResize fires inside Flutter's
    // LayoutBuilder build phase, so any ValueNotifier/overlay mutations here
    // would crash with "setState() called during build".
    final capturedLayout = newLayout;
    final wasGameOver = _isGameOver;
    final savedScore = _score;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      layout = capturedLayout;
      _rebuilding = true;
      _teardownComponents();
      _initState();
      _buildComponents().then((_) {
        _rebuilding = false;
        if (wasGameOver) {
          _score = savedScore;
          _isGameOver = true;
          pauseButtonVisibleNotifier.value = false;
          overlays.add(kOverlayGameOver);
        } else {
          _showStartScreen();
        }
      });
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isGameOver || _isPaused || _rebuilding || _waitingToStart) return;

    _moveTimer += dt;
    if (_moveTimer >= _moveSpeed) {
      _moveTimer = 0;
      _currentDir = _nextDir;
      _step();
      // Promote the queued direction into the active slot after each step.
      if (_queuedDir != null) {
        _nextDir = _queuedDir!;
        _queuedDir = null;
      }
    }

    // Sync visuals every frame.
    _snakeComp.body = List.from(_snake);
    _scoreText.text = 'SCORE: $_score';
  }

  // ── Component lifecycle helpers ────────────────────────────────────────────

  // Vertically centre 12 px score text within the HUD strip.
  double get _scoreTextY => layout.gridH + (layout.hudHeight - 12) / 2;

  Future<void> _buildComponents() async {
    _board = GameBoard(layout);
    await world.add(_board);

    _snakeComp = SnakeComponent(layout);
    await world.add(_snakeComp);

    _foodComp = FoodComponent(layout);
    await world.add(_foodComp);
    _syncFood();

    _scoreText = TextComponent(
      text: 'SCORE: 0',
      textRenderer: TextPaint(
        style: GoogleFonts.pressStart2p(
          textStyle: const TextStyle(
            color: Color(0xFF39FF14),
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
      ),
      position: Vector2(8, _scoreTextY),
    );
    await camera.viewport.add(_scoreText);
    hudHeightNotifier.value = layout.hudHeight;
  }

  void _teardownComponents() {
    world.removeAll(world.children.toList());
    camera.viewport.removeAll(camera.viewport.children.toList());
    overlays.clear();
    _isPaused = false;
    _isGameOver = false;
    // pauseButtonVisibleNotifier is managed by _showStartScreen / startGame.
  }

  /// Update layout reference on existing components (no rebuild needed when
  /// only the cell size changes, not the grid dimensions).
  void _updateComponentLayouts() {
    _board.layout = layout;
    _snakeComp.layout = layout;
    _foodComp.layout = layout;
    _scoreText.position = Vector2(8, _scoreTextY);
    hudHeightNotifier.value = layout.hudHeight;
  }

  // ── Game logic ─────────────────────────────────────────────────────────────

  void _initState() {
    _snake
      ..clear()
      ..addAll([
        Point(layout.cols ~/ 2, layout.rows ~/ 2),
        Point(layout.cols ~/ 2 - 1, layout.rows ~/ 2),
        Point(layout.cols ~/ 2 - 2, layout.rows ~/ 2),
      ]);
    _currentDir = Direction.right;
    _nextDir = Direction.right;
    _queuedDir = null;
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
      candidate = Point(rng.nextInt(layout.cols), rng.nextInt(layout.rows));
    } while (_snake.contains(candidate));
    _food = candidate;
  }

  void _syncFood() {
    _foodComp.position = Vector2(_food.x * layout.cell, _food.y * layout.cell);
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
    if (next.x < 0 ||
        next.x >= layout.cols ||
        next.y < 0 ||
        next.y >= layout.rows) {
      _triggerGameOver();
      return;
    }

    // Self-collision — exclude the tail because it will vacate its cell.
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
    pauseButtonVisibleNotifier.value = false;
    overlays.add(kOverlayGameOver);
  }

  void _restart() {
    _initState();
    _syncFood();
    _snakeComp.body = List.from(_snake);
    _scoreText.text = 'SCORE: 0';
    _showStartScreen();
  }

  void _showStartScreen() {
    _waitingToStart = true;
    pauseButtonVisibleNotifier.value = false;
    overlays.add(kOverlayStartScreen);
  }

  // ── Keyboard input (desktop) ───────────────────────────────────────────────

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Start screen: Enter / Space / any arrow key begins the game.
    if (_waitingToStart) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW ||
          event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.keyS ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA ||
          event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        startGame();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // Block keys when game-over or leaderboard overlays are active.
    if (overlays.isActive(kOverlayGameOver) &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      restart();
      return KeyEventResult.handled;
    }
    if (overlays.isActive(kOverlayLeaderboard) &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      overlays.remove(kOverlayLeaderboard);
      if (_leaderboardPausedGame) {
        // Was opened mid-game — keep the game paused, restore pause overlay.
        _leaderboardPausedGame = false;
        pauseButtonVisibleNotifier.value = false;
        overlays.add(kOverlayPause);
      } else {
        // Was opened from game-over — prepare start screen, don't auto-start.
        _restart();
      }
      return KeyEventResult.handled;
    }

    if (overlays.isActive(kOverlayGameOver) ||
        overlays.isActive(kOverlayLeaderboard)) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW) {
      _queueDirection(Direction.up, Direction.down);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS) {
      _queueDirection(Direction.down, Direction.up);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      _queueDirection(Direction.left, Direction.right);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      _queueDirection(Direction.right, Direction.left);
    } else if (event.logicalKey == LogicalKeyboardKey.keyP ||
        event.logicalKey == LogicalKeyboardKey.escape) {
      togglePause();
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  /// Queue a direction change, using a two-slot buffer so rapid key presses
  /// (faster than one game step) are not silently dropped.
  ///
  /// [opposite] is the direction that would cause a 180° reversal from [dir].
  void _queueDirection(Direction dir, Direction opposite) {
    // If _nextDir already differs from current (i.e. a turn is buffered),
    // store this press in the second slot — but only if it's a valid turn
    // from _nextDir's perspective.
    if (_nextDir != _currentDir) {
      if (_nextDir != opposite && dir != opposite) _queuedDir = dir;
    } else {
      if (_currentDir != opposite) _nextDir = dir;
    }
  }

  // ── Touch / swipe input (mobile & web) ────────────────────────────────────

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
    // Ignore micro-taps or when overlays are open.
    if (_dragDelta.length < 20 || _isGameOver || _isPaused) {
      return;
    }

    if (_dragDelta.x.abs() > _dragDelta.y.abs()) {
      if (_dragDelta.x > 0 && _currentDir != Direction.left) {
        _nextDir = Direction.right;
      } else if (_dragDelta.x < 0 && _currentDir != Direction.right) {
        _nextDir = Direction.left;
      }
    } else {
      if (_dragDelta.y > 0 && _currentDir != Direction.up) {
        _nextDir = Direction.down;
      } else if (_dragDelta.y < 0 && _currentDir != Direction.down) {
        _nextDir = Direction.up;
      }
    }
  }
}
