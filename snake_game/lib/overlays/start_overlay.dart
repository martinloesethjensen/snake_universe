import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snake_game/snake_game.dart';

class StartOverlay extends StatefulWidget {
  const StartOverlay({super.key, required this.game});

  final SnakeGame game;

  @override
  State<StartOverlay> createState() => _StartOverlayState();
}

class _StartOverlayState extends State<StartOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _opacity = Tween(
      begin: 0.25,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    final px = GoogleFonts.pressStart2p;
    final prompt = _isMobile ? 'TAP TO PLAY' : 'PRESS ENTER TO PLAY';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.game.startGame,
      child: Container(
        color: Colors.black.withValues(alpha: 0.72),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'SNAKE',
                style: px(
                  textStyle: const TextStyle(
                    color: Color(0xFF39FF14),
                    fontSize: 36,
                    letterSpacing: 6,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'UNIVERSE',
                style: px(
                  textStyle: const TextStyle(
                    color: Color(0xFF1A6B00),
                    fontSize: 11,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 56),
              // Pulsating prompt
              AnimatedBuilder(
                animation: _opacity,
                builder: (context, _) => Opacity(
                  opacity: _opacity.value,
                  child: Text(
                    prompt,
                    style: px(
                      textStyle: const TextStyle(
                        color: Color(0xFF39FF14),
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
