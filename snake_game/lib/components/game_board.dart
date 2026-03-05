import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../constants.dart';

/// Renders the static background: dark grid area + HUD strip.
class GameBoard extends PositionComponent {
  GameBoard() : super(position: Vector2.zero(), size: Vector2(kGameW, kGameH));

  static const _bgColor = Color(0xFF0D1117);
  static const _hudBg = Color(0xFF07100A);
  static const _gridColor = Color(0xFF1A2B1A);
  static const _hudBorder = Color(0xFF39FF14);

  final _bgPaint = Paint()..color = _bgColor;
  final _hudPaint = Paint()..color = _hudBg;
  final _gridPaint = Paint()
    ..color = _gridColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5;
  final _borderPaint = Paint()
    ..color = _hudBorder
    ..strokeWidth = 1.0;

  @override
  void render(Canvas canvas) {
    // Game area
    canvas.drawRect(Rect.fromLTWH(0, 0, kGameW, kRows * kCell), _bgPaint);

    // HUD strip
    canvas.drawRect(
      Rect.fromLTWH(0, kRows * kCell, kGameW, kHudHeight),
      _hudPaint,
    );

    // Neon border line between game area and HUD
    canvas.drawLine(
      Offset(0, kRows * kCell),
      Offset(kGameW, kRows * kCell),
      _borderPaint,
    );

    // Subtle grid lines
    for (var col = 0; col <= kCols; col++) {
      final x = col * kCell;
      canvas.drawLine(Offset(x, 0), Offset(x, kRows * kCell), _gridPaint);
    }
    for (var row = 0; row <= kRows; row++) {
      final y = row * kCell;
      canvas.drawLine(Offset(0, y), Offset(kGameW, y), _gridPaint);
    }
  }
}
