import 'dart:math' show sin;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game_layout.dart';

/// Renders the food token with a neon-pink pulsing animation.
class FoodComponent extends PositionComponent {
  FoodComponent(this.layout);

  GameLayout layout;

  double _t = 0;

  @override
  void update(double dt) => _t += dt;

  @override
  void render(Canvas canvas) {
    final cell = layout.cell;
    final pulse = (sin(_t * 5) + 1) / 2; // oscillates 0..1

    // Outer block (shrinks/grows)
    final pad = 2.0 + pulse * 2.5;
    canvas.drawRect(
      Rect.fromLTWH(pad, pad, cell - pad * 2, cell - pad * 2),
      Paint()..color = const Color(0xFFFF3366),
    );

    // Bright inner pixel highlight
    canvas.drawRect(
      Rect.fromLTWH(pad + 2, pad + 2, 4, 4),
      Paint()
        ..color = Color.fromARGB((120 + (pulse * 135).round()), 255, 200, 220),
    );
  }
}
