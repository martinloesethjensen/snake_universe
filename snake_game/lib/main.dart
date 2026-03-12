import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snake_game/overlays/game_over_overlay.dart';
import 'package:snake_game/overlays/leaderboard_overlay.dart';
import 'package:snake_game/overlays/pause_overlay.dart';
import 'package:snake_game/overlays/start_overlay.dart';
import 'package:snake_game/services/api_service.dart';
import 'package:snake_game/snake_game.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Font is bundled locally — never fetch from the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabasePublishableKey,
  );
  final game = SnakeGame();
  final api = ApiService();
  runApp(_SnakeApp(game: game, api: api));
}

class _SnakeApp extends StatefulWidget {
  const _SnakeApp({required this.game, required this.api});

  final SnakeGame game;
  final ApiService api;

  @override
  State<_SnakeApp> createState() => _SnakeAppState();
}

class _SnakeAppState extends State<_SnakeApp> {
  final _gameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.game.gameFocusNode = _gameFocusNode;
  }

  @override
  void dispose() {
    _gameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              GameWidget<SnakeGame>(
                game: widget.game,
                focusNode: _gameFocusNode,
                overlayBuilderMap: {
                  kOverlayStartScreen: (_, g) => StartOverlay(game: g),
                  kOverlayGameOver: (_, g) => GameOverOverlay(game: g, api: widget.api),
                  kOverlayLeaderboard: (_, g) => LeaderboardOverlay(game: g, api: widget.api),
                  kOverlayPause: (_, g) => PauseOverlay(game: g),
                },
              ),
              // Pause + trophy buttons — sized to match the HUD strip so they
              // stay vertically aligned with the SCORE text.
              ValueListenableBuilder<double>(
                valueListenable: widget.game.hudHeightNotifier,
                builder: (context, hudH, _) => Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: hudH,
                  child: Row(
                    children: [
                      // Left: invisible spacer to balance the trophy button.
                      const Expanded(child: SizedBox()),
                      // Centre: pause button (hidden when overlay is active).
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.game.pauseButtonVisibleNotifier,
                        builder: (_, visible, child) =>
                            Visibility(visible: visible, child: child!),
                        child: Center(child: _PauseButton(game: widget.game)),
                      ),
                      // Right: trophy button.
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _TrophyButton(game: widget.game),
                        ),
                      ),
                    ],
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
