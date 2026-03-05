import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snake_game/snake_game.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  final SnakeGame game;

  @override
  Widget build(BuildContext context) {
    final px = GoogleFonts.pressStart2p;
    const neon = Color(0xFF39FF14);

    return Material(
      color: Colors.black.withValues(alpha: 0.80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PAUSED',
              style: px(
                textStyle: const TextStyle(
                  color: neon,
                  fontSize: 22,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: game.togglePause,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: neon),
                  color: Colors.black,
                ),
                child: Text(
                  '[ RESUME ]',
                  style: px(
                    textStyle: const TextStyle(color: neon, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
