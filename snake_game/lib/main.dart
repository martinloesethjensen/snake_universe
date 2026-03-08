import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snake_game/overlays/game_over_overlay.dart';
import 'package:snake_game/overlays/leaderboard_overlay.dart';
import 'package:snake_game/overlays/pause_overlay.dart';
import 'package:snake_game/overlays/start_overlay.dart';
import 'package:snake_game/snake_game.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Font is bundled locally — never fetch from the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabasePublishableKey);
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
                kOverlayStartScreen: (_, g) => StartOverlay(game: g),
                kOverlayGameOver: (_, g) => GameOverOverlay(game: g),
                kOverlayLeaderboard: (_, g) => LeaderboardOverlay(game: g),
                kOverlayPause: (_, g) => PauseOverlay(game: g),
              },
            ),
            // Pause button — anchored to the bottom-center of the HUD strip.
            // Hidden from interaction while the pause overlay is shown.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 40,
              child: ValueListenableBuilder<bool>(
                valueListenable: game.pauseButtonVisibleNotifier,
                builder: (_, visible, child) =>
                    Visibility(visible: visible, child: child!),
                child: Center(child: _PauseButton(game: game)),
              ),
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

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.game});

  final SnakeGame game;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Pause (P / Esc)',
      child: GestureDetector(
        onTap: game.togglePause,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.pause_outlined, color: Color(0xFF39FF14), size: 22),
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
