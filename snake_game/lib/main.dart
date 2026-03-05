import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snake_game/overlays/game_over_overlay.dart';
import 'package:snake_game/overlays/leaderboard_overlay.dart';
import 'package:snake_game/snake_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Font is bundled locally — never fetch from the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  final game = SnakeGame();
  runApp(_SnakeApp(game: game));
}

class _SnakeApp extends StatelessWidget {
  const _SnakeApp({required this.game});

  final SnakeGame game;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GameWidget<SnakeGame>(
              game: game,
              overlayBuilderMap: {
                kOverlayGameOver: (_, g) => GameOverOverlay(game: g),
                kOverlayLeaderboard: (_, g) => LeaderboardOverlay(game: g),
              },
            ),
            // Trophy button — anchored to the bottom-right of the HUD strip.
            Positioned(
              right: 8,
              bottom: 0,
              height: 40,
              child: _TrophyButton(game: game),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrophyButton extends StatelessWidget {
  const _TrophyButton({required this.game});

  final SnakeGame game;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Leaderboard',
      child: GestureDetector(
        onTap: game.openLeaderboard,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFF39FF14),
                size: 22,
              ),
              const SizedBox(width: 4),
              Text(
                'TOP',
                style: GoogleFonts.pressStart2p(
                  textStyle: const TextStyle(
                    color: Color(0xFF39FF14),
                    fontSize: 8,
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
