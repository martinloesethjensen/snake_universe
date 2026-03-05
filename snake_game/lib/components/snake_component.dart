import 'dart:math' show Point, max;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../constants.dart';

/// Renders the snake body from head (index 0) to tail in a retro 8-bit style.
/// The [body] list is set each frame by [SnakeGame] before rendering.
class SnakeComponent extends Component {
  List<Point<int>> body = const [];

  static const _headColor = Color(0xFF39FF14); // neon green
  static const _eyeColor = Color(0xFF001A00);
  static const _specColor = Color(0xFF88FF88);

  @override
  void render(Canvas canvas) {
    // Draw tail-to-head so the head renders on top.
    for (var i = body.length - 1; i >= 0; i--) {
      final seg = body[i];
      final x = seg.x * kCell;
      final y = seg.y * kCell;
      if (i == 0) {
        _renderHead(canvas, x, y);
      } else {
        _renderSegment(canvas, x, y, i, body.length);
      }
    }
  }

  void _renderHead(Canvas canvas, double x, double y) {
    // Slightly rounded neon-green head block
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 1, y + 1, kCell - 2, kCell - 2),
        const Radius.circular(4),
      ),
      Paint()..color = _headColor,
    );
    // Eyes
    final eyeR = kCell * 0.11;
    canvas.drawCircle(
      Offset(x + kCell * 0.28, y + kCell * 0.30),
      eyeR,
      Paint()..color = _eyeColor,
    );
    canvas.drawCircle(
      Offset(x + kCell * 0.72, y + kCell * 0.30),
      eyeR,
      Paint()..color = _eyeColor,
    );
  }

  void _renderSegment(Canvas canvas, double x, double y, int index, int total) {
    // Fade from bright green near head to dark green at tail.
    final t = index / max(total - 1, 1); // 0 = just behind head, 1 = tail
    final green = (180 - (t * 80).round()).clamp(40, 180);
    final alpha = (255 - (t * 80).round()).clamp(100, 255);

    canvas.drawRect(
      Rect.fromLTWH(x + 1, y + 1, kCell - 2, kCell - 2),
      Paint()..color = Color.fromARGB(alpha, 0, green, 0),
    );

    // Retro pixel specular dot
    canvas.drawRect(
      Rect.fromLTWH(x + 3, y + 3, 3, 3),
      Paint()..color = _specColor.withAlpha((alpha * 0.35).round()),
    );
  }
}
