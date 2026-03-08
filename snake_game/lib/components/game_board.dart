import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game_layout.dart';

/// Renders the static background: dark grid area + HUD strip.
class GameBoard extends PositionComponent {
  GameBoard(this.layout) : super(position: Vector2.zero());

  GameLayout layout;

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
    final l = layout;
    final gridW = l.gridW;
    final gridH = l.gridH;
    final cell = l.cell;

    // Game area
    canvas.drawRect(Rect.fromLTWH(0, 0, gridW, gridH), _bgPaint);

    // HUD strip
    canvas.drawRect(Rect.fromLTWH(0, gridH, gridW, l.hudHeight), _hudPaint);

    // Neon border line between game area and HUD
    canvas.drawLine(Offset(0, gridH), Offset(gridW, gridH), _borderPaint);

    // Subtle grid lines
    for (var col = 0; col <= l.cols; col++) {
      final x = col * cell;
      canvas.drawLine(Offset(x, 0), Offset(x, gridH), _gridPaint);
    }
    for (var row = 0; row <= l.rows; row++) {
      final y = row * cell;
      canvas.drawLine(Offset(0, y), Offset(gridW, y), _gridPaint);
    }
  }
}
